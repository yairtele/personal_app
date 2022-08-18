import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:navigation_app/services/business/batch_states.dart';
import 'package:navigation_app/services/business/return_photo.dart';
import 'package:navigation_app/services/sp_ws/web_service_exception.dart';
import 'package:navigation_app/utils/sp_asset_utils.dart';
import 'package:navigation_app/utils/ui/sp_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/business_exception.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/services/business/new_return.dart';
import 'package:navigation_app/services/business/product_info.dart';
import 'package:navigation_app/services/business/return_request.dart';
import 'package:navigation_app/ui/screen_data.dart';
import 'package:navigation_app/utils/ui/thumb_photo.dart';
import 'package:navigation_app/utils/ui/working_indicator_dialog.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../app_state.dart';
import 'package:intl/intl.dart';

import '../config/configuration.dart';

//T extends StatefulWidget
class NewReturnScreen extends StatefulWidget {
  final ReturnRequest? returnRequest; //TODO: Precargar datos si returnRequest no es nulo
  final Batch batch;
  const NewReturnScreen({Key? key, required this.batch, this.returnRequest}) : super(key: key);

  @override
  State<NewReturnScreen> createState() => _NewReturnScreenState();
}
//K extends State<T>
class _NewReturnScreenState extends State<NewReturnScreen> {
  final _searchParamTextController = TextEditingController();
  final _retailReferenceTextController = TextEditingController();
  final _quantityTextController = TextEditingController();
  final _commentsTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();
  final _brandTextController = TextEditingController();
  final _legalEntityTextController = TextEditingController();
  final _dateTextController = TextEditingController();
  final _eanTextController = TextEditingController();
  final _commercialCodeTextController = TextEditingController();

  //XFile imageFile;
  final Map<String, ThumbPhoto> _takenPictures = {};
  bool _isAuditableProduct = false;
  var _productSearchBy = ProductSearchBy.EAN;
  ReturnRequest? _existingReturnRequest;
  ProductInfo? _product;
  DateTime? _productLastSell;
  String? _lastSellPrice;
  Future<ScreenData<void, void>>? _localData;
  late Batch _globalBatch;
  String _dateWarning = '';
  bool _shouldRefreshParent = false;
  late final XFile _dummyPhoto;

  @override
  void initState() {
    super.initState();
    _globalBatch = widget.batch;
    _localData = ScreenData<void, void>(dataGetter: _initializeScreen).getScreenData();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final newReturnState = this;
    return WillPopScope(
      onWillPop: () {

        appState.returnWith(_shouldRefreshParent);
        _shouldRefreshParent = false;

        //we need to return a future
        return Future.value(false);
      },
      child: FutureBuilder<ScreenData<void, void>>(
          future: _localData,
          builder: (BuildContext context,
              AsyncSnapshot<ScreenData<void, void>> snapshot) {
            Widget widget;
            if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
              final batch = this.widget.batch;
              _globalBatch = batch;
              widget = Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Configuration.customerPrimaryColor,
                    title: const Text(
                      'Nueva Devolución',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                  body: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints viewportConstraints) {
                    return SingleChildScrollView(
                      //SafeArea(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewportConstraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: RadioListTile<ProductSearchBy>(
                                      title: const Text('EAN'),
                                      groupValue: _productSearchBy,
                                      value: ProductSearchBy.EAN,
                                      onChanged: (value) {
                                        setState(() {
                                          _productSearchBy = value!;
                                        });
                                      },
                                    )),
                                Expanded(
                                    child: RadioListTile<ProductSearchBy>(
                                      title: const Text('Cod. comercial'),
                                      groupValue: _productSearchBy,
                                      value: ProductSearchBy.CommercialCode,
                                      onChanged: (value) {
                                        setState(() {
                                          _productSearchBy = value!;
                                        });
                                      },
                                    )),
                              ],
                            ),
                            //Text('ID Lote Retail: '),
                            Row(
                              children: [
                                Expanded(
                                    child: Container(
                                      //margin: UIHelper.formFieldContainerMargin,
                                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),//UIHelper.formFieldContainerPadding,
                                      child: TextField(
                                        autofocus: true,
                                        controller: _searchParamTextController,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.send,
                                        maxLength: 30,
                                        decoration: const InputDecoration(
                                            hintText: 'EAN/MOD',
                                            helperText: 'Ej: 939482'),
                                      ),
                                    )),
                                if(Platform.isAndroid)
                                  Container(
                                  width: 45,
                                  //margin: UIHelper.formFieldContainerMargin,
                                  padding: const EdgeInsets.only(left: 2, right: 2),
                                  child: ElevatedButton(
                                    child: const Icon(FontAwesomeIcons.barcode),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.only(left: 0, right: 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () async {
                                      //if (Platform.isAndroid || Platform.isIOS) {
                                          FocusManager.instance.primaryFocus?.unfocus();
                                          final barcode = await BarcodeScanner.scan();
                                          if (barcode.type.value == 0) //la lectura fue exitosa
                                            _lookForProduct(barcode);
                                        //}
                                      //}
                                    },
                                  ),
                                ),
                                Container(
                                  width: 45,
                                  //margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.only(left: 2, right: 2),
                                  child: ElevatedButton(
                                    child: const Icon(// Botón Buscar
                                        FontAwesomeIcons.search),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.only(left: 0, right: 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: _lookForProduct,
                                  ),
                                ),
                              ],
                            ),

                            if (_product != null) ...[
                              Container(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        //margin: const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                                        child: TextField(
                                          controller: _descriptionTextController,
                                          autofocus: true,
                                          keyboardType: TextInputType.text,
                                          textInputAction:
                                          TextInputAction.send,
                                          readOnly: true,
                                          maxLength: 30,
                                          decoration: const InputDecoration(
                                              labelText: 'Descripción',
                                              border: InputBorder.none,
                                              counter: Offstage()
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _eanTextController,
                                              autofocus: false,
                                              keyboardType: TextInputType.number,
                                              textInputAction:
                                              TextInputAction.send,
                                              readOnly: true,
                                              maxLength: 13,
                                              decoration: const InputDecoration(
                                                  labelText: 'EAN',
                                                  border: InputBorder.none,
                                                  counter: Offstage()
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: TextField(
                                              controller: _commercialCodeTextController,
                                              autofocus: false,
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                              TextInputAction.send,
                                              readOnly: true,
                                              maxLength: 30,
                                              decoration: const InputDecoration(
                                                  labelText: 'Código Comercial',
                                                  border: InputBorder.none,
                                                  counter: Offstage()
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _brandTextController,
                                                autofocus: true,
                                                keyboardType: TextInputType.text,
                                                textInputAction:
                                                TextInputAction.send,
                                                readOnly: true,
                                                maxLength: 30,
                                                decoration: const InputDecoration(
                                                    labelText: 'Marca',
                                                    border: InputBorder.none,
                                                    counter: Offstage()
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: TextField(
                                                controller: _legalEntityTextController,
                                                autofocus: true,
                                                keyboardType: TextInputType.text,
                                                textInputAction:
                                                TextInputAction.send,
                                                readOnly: true,
                                                maxLength: 30,
                                                decoration: const InputDecoration(
                                                    labelText: 'Jurídica',
                                                    border: InputBorder.none,
                                                    counter: Offstage()
                                                ),
                                              ),
                                            ),
                                          ]),
                                      Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _dateTextController,
                                                autofocus: true,
                                                keyboardType: TextInputType.text,
                                                textInputAction:
                                                TextInputAction.send,
                                                readOnly: true,
                                                maxLength: 30,

                                                decoration: const InputDecoration(
                                                    labelText: 'Fecha Última Compra',
                                                    border: InputBorder.none,
                                                    counter: Offstage()
                                                ),
                                              ),
                                            )
                                          ]),
                                      if(_dateWarning != '')
                                        const Icon(FontAwesomeIcons.exclamationTriangle),
                                        const Padding(
                                          padding: EdgeInsets.only(top: 5)
                                        ),
                                        Text(_dateWarning,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red
                                            )),
                                      Row(
                                        children:[
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(30, 0, 10, 0),
                                              child: TextField(
                                              controller: _retailReferenceTextController,
                                              autofocus: true,
                                              keyboardType:
                                              TextInputType.text,
                                              textInputAction:
                                              TextInputAction.send,
                                              maxLength: 30,
                                              decoration: const InputDecoration(
                                                  labelText:
                                                  'Referencia interna',
                                                  helperText:'Ej: AEF54216CV'
                                              ),
                                            ),
                                          )),
                                          if (Platform.isAndroid)
                                            Container(
                                              width: 45,
                                              margin: const EdgeInsets.only(top: 8),
                                              padding: const EdgeInsets.only(left: 2, right: 2),
                                              child: ElevatedButton(
                                                child: const Icon(FontAwesomeIcons.barcode),
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.only(left: 0, right: 0),
                                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                ),
                                                onPressed: () async {
                                                    //if (Platform.isAndroid || Platform.isIOS) {
                                                      FocusManager.instance.primaryFocus?.unfocus();
                                                      final barcode = await BarcodeScanner.scan();
                                                      if (barcode.type.value == 0)
                                                        setState(() {
                                                          _retailReferenceTextController.text = barcode.rawContent;
                                                        });
                                                    //}
                                                },
                                              ),
                                            )]
                                      ),
                                      Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            if (!_isAuditableProduct)
                                              Container(
                                                margin: const EdgeInsets.only(top: 8),
                                                padding: const EdgeInsets.all(30),
                                                child: TextField(
                                                  controller: _quantityTextController,
                                                  autofocus: true,
                                                  keyboardType:
                                                  TextInputType.number,
                                                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                                  textInputAction: TextInputAction.send,
                                                  maxLength: 10,
                                                  decoration:
                                                  const InputDecoration(
                                                      labelText:
                                                      'Cantidad devuelta',
                                                      helperText:
                                                      'Ej: 12'),
                                                  //},
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.fromLTRB(30,0,30,15),
                                                child: TextField(
                                                  controller: _commentsTextController,
                                                  autofocus: true,
                                                  keyboardType:
                                                  TextInputType.multiline,
                                                  textInputAction:
                                                  TextInputAction.send,
                                                  maxLines: null,
                                                  maxLength: 50,
                                                  decoration:
                                                  const InputDecoration(
                                                      labelText:
                                                      'Observaciones',
                                                      helperText:
                                                      'Ej: Grietas'),
                                                  //},
                                                ),
                                              ),
                                            SpUI.buildThumbnailsGridView(state: newReturnState, photos:  _takenPictures, dummyPhoto: _dummyPhoto, photoParentState: _existingReturnRequest?.state ?? BatchStates.Draft, context: context),
                                          ]),
                                    ]),
                                //)
                                //)
                              ),
                              Padding(
                                //margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.fromLTRB(0,8,0,8),//all(15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton( // Botón Registrar
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.save),
                                          const Text('Registrar')
                                        ]
                                      ),
                                      onPressed: () async {
                                        try{
                                          WorkingIndicatorDialog().show(context, text: 'Registrando nueva devolución...');
                                          //validateProductData();

                                          final photosToSave = _takenPictures.map(
                                                  (key, thumbPhoto) => MapEntry(key, ReturnPhoto(path: thumbPhoto.photo.path, isDummy: thumbPhoto.isDummy))
                                          );

                                          final product = _product!;
                                          final newReturn = NewReturn(
                                            EAN: product.EAN,
                                            sku: product.sku,
                                            retailReference: _retailReferenceTextController.text,
                                            commercialCode: product.commercialCode,
                                            brand: product.brand,
                                            description: product.description,
                                            lastSell: _productLastSell,
                                            price: _lastSellPrice,
                                            legalEntity: product.legalEntity,
                                            businessUnit: product.businessUnit,
                                            quantity: _getQuantity(),
                                            isAuditable: _isAuditableProduct,
                                            photos: photosToSave,
                                            observations: _commentsTextController.text,
                                            customer_account: product.salesInfo != null? product.salesInfo!.retailAccount : '(No disponible)'
                                          );
                                          //print('GLOBAL BATCH: ' + batch.batchNumber!);
                                          await BusinessServices.registerNewProductReturn(batch: batch, existingReturnRequest: _existingReturnRequest, newReturn:  newReturn);

                                          _shouldRefreshParent = true;
                                          _showSuccessfulSnackBar('La nueva devolución fue registrada con éxito');
                                          _clearProductFields();
                                          setState(() {

                                          });
                                        }
                                        on BusinessException catch(e){
                                          _showErrorSnackBar(e.message);
                                        }
                                        catch (e){
                                          //TODO: EN GENRERAL: los errores inesperados se deben loguear o reportar al equipo de soporte atomáticamente
                                          //TODO: EN GENERAL: Detectar si los errores se deben a falta de conexión a internet, y ver como se loguean o reportan estos casos
                                          _showErrorSnackBar('Ha ocurrido un error al guardar la nueva devolución. Error: ${e}');
                                        }
                                        finally{
                                          WorkingIndicatorDialog().dismiss();
                                        }
                                      },
                                ),
                              ]
                              )),
                            ],
                          ],
                        ),
                      ),
                    );
                  }));
            } else if (snapshot.hasError) {
              widget = Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'),
                    )
                  ],
                ),
              );
            } else {
              widget = Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text('Aguarde un momento por favor...'),
                        )
                      ]));
            }
            return widget;
          }),
    );

  }

  Future<ProductInfo> _getProductInfoByCommercialCode(String commercialCode) {
    return BusinessServices.getProductInfoByCommercialCode(commercialCode);
  }

  void _showErrorSnackBar(String message) {
    _showSnackBar(message, Colors.red);
  }
  void _showSuccessfulSnackBar(String message) {
    _showSnackBar(message, Colors.green);
  }
  void _showSnackBar(String message, MaterialColor bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: bgColor),
    );
  }

  Future<ReturnRequest?> _getExistingReturnRequestInBatch({required Batch batch, required ProductInfo productInfo}) async {
    ReturnRequest? existingReturnRequest;
    // Buscar todas las solicitudes del batch.
    final returnRequests = await BusinessServices.getReturnRequestsByBatchUUID(batchUUID: batch.uuid!);

    // Si no hay ninguna, retornar null
    if(returnRequests.length == 0){
      return null;
    }


    if (productInfo.isAuditable == true){
      // Entre las existentes, buscar las que tienen el mismo EAN que el producto a devolver
      final returnRequestsWithSameEAN = returnRequests.where((returnRequest) => returnRequest.EAN == productInfo.EAN);
      if(returnRequestsWithSameEAN.length > 1){
        throw BusinessException('No debería haber más de una solicitud de devolución con el mismo EAN  para productos auditables.');
      } else if (returnRequestsWithSameEAN.length == 1) {
        existingReturnRequest = returnRequestsWithSameEAN.first;
      } else {
        existingReturnRequest = null;
      }
    }
    else {
      // Por ahora no importa si existe otra solicitud con el mismo EAN. Luego podemos mostrar un cartelito sugiriendo que actualice
      // la cantidad en la existente.
    }

    return existingReturnRequest;
  }

  void _clearProductFields() {
    _product = null;
    _retailReferenceTextController.text = '';
    _quantityTextController.text = '';
    _descriptionTextController.text = '';
    _dateTextController.text = '';
    _eanTextController.text = '';
    _commercialCodeTextController.text = '';
    _brandTextController.text = '';
    _legalEntityTextController.text = '';
    _commentsTextController.text = '';

    _takenPictures.clear();
  }

  int? _getQuantity() {
    int? quantity = null;

    if(!_product!.isAuditable) {
      quantity = int.tryParse(_quantityTextController.text);
      if(quantity == null || quantity <= 0){
        throw BusinessException('Por favor indique la cantidad a devolver. No puede ser cero ni vacía.');
      }
    }
    return quantity;
  }

  Future<void> _initializeScreen(nothing) async{
    _dummyPhoto = await SpAssetUtils.getImageXFileFromAssets('images/img_not_found.jpg');
  }

  void _lookForProduct ([ScanResult? barcode]) async {
    try {
      // Limpiar campos
      _clearProductFields();

      if(barcode != null){
        _searchParamTextController.text = barcode.rawContent;
      }
      WorkingIndicatorDialog().show(context, text: 'Buscando información de producto...');
      // Buscar info del producto y actualizar el Future del FutureBuilder.
      late ProductInfo productInfo;
      try {
        if (_productSearchBy == ProductSearchBy.EAN) {
          productInfo = await BusinessServices.getProductInfoByEAN(
              _searchParamTextController.text);
        } else {
          productInfo = await _getProductInfoByCommercialCode(
              _searchParamTextController.text);
        }
      } on WebServiceException catch(e) {
        var message = 'No fue posible hallar el producto indicado.';
        try{
          if (e.response != null) {
            final responseMessage = const Utf8Decoder().convert(e.response!.bodyBytes);
            final regexp = RegExp(r'error=(.+?)\)');
            final match = regexp.firstMatch(responseMessage);
            if(match != null) {
              message = match.group(1)!;
            }
          }
        }catch(err){}

        throw BusinessException(message);
      } catch(e){
        throw BusinessException('No fue posible hallar el producto indicado.');
      }
        // Cargar datos del producto
        _descriptionTextController.text = productInfo.description;
        final formatter = DateFormat('dd/MM/yyyy');
        _dateTextController.text = productInfo.salesInfo != null ? formatter.format(productInfo.salesInfo!.lastSellDate).toString() : '(No diponible)';
        //_priceTextController.text = productInfo.salesInfo != null ? productInfo.salesInfo!.price.toString() : '(No diponible)';
        _brandTextController.text = productInfo.brand;
        _legalEntityTextController.text = productInfo.legalEntity;
        _eanTextController.text = productInfo.EAN;
        _commercialCodeTextController.text = productInfo.commercialCode;
        _productLastSell = productInfo.salesInfo?.lastSellDate;
        final dateWarning = _dateValidation(productInfo);


        if (productInfo.auditRules.photos.length == 0){
          _takenPictures['otra'] = ThumbPhoto(photo: _dummyPhoto, isDummy: true, hasChanged: true, state: BatchStates.Draft);
        }
        else{
          productInfo.auditRules.photos.forEach((photoAuditInfo) {
            _takenPictures[photoAuditInfo.name] = ThumbPhoto(photo: _dummyPhoto, isDummy: true, hasChanged: true, state: BatchStates.Draft);
          });
        }

        //TODO: Mostrar advertecia de que ya existe una solicitud con el mismo EAN en caso de que el producto NO SEA auditable
        final existingReturnRequest = await _getExistingReturnRequestInBatch(batch: _globalBatch, productInfo: productInfo);

        setState(() {
          _isAuditableProduct = productInfo.isAuditable;
          _existingReturnRequest = existingReturnRequest;
          _product = productInfo;
          _dateWarning = dateWarning;
        });
    }
    on BusinessException catch (e) {
      _showErrorSnackBar(
          'Error recuperando información del producto: ${e
              .message}');
    }
    on Exception catch (e) {
      _showErrorSnackBar(
          'Ha ocurrido un error inesperado: $e');
    }
    finally{
      WorkingIndicatorDialog().dismiss();
    }
  }

  String _dateValidation(ProductInfo productInfo){

    _lastSellPrice = null;

    if(productInfo.salesInfo == null) {
      return 'No se encontró información sobre la última compra. La devolución podría ser rechazada por el auditor.';
    }

    final lastSell = productInfo.salesInfo!.lastSellDate;

    if(lastSell != null && DateTime.now().difference(lastSell).inDays > productInfo.auditRules.lastSaleMaxAge.inDays){

      _lastSellPrice = '\$' +productInfo.salesInfo!.price.toString();
      return 'La última compra fue realizada hace más de ${productInfo.auditRules.lastSaleMaxAge.inDays} días. La devolución podría ser rechazada por el auditor.';
    } else {
      return '';
    }
  }

  void validateProductData(){

      try {
        const eanPattern = r'^[\w]{6,14}$';
        final eanRegex = RegExp(eanPattern);
        if (!eanRegex.hasMatch(_product!.EAN))
          throw BusinessException('EAN');
      } catch(e){
        throw BusinessException('Debe ingresar datos válidos para la carga de la solicitud. Error en el dato: ' + e.toString());
      }
  }
}



enum ProductSearchBy { EAN, CommercialCode }
