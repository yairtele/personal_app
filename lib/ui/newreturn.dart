//import 'dart:html';

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
import 'package:navigation_app/utils/ui/working_indicator_dialog.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../app_state.dart';
import 'package:intl/intl.dart';

//T extends StatefulWidget
class NewReturnScreen extends StatefulWidget {
  final ReturnRequest? returnRequest;
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
  final _descriptionTextController = TextEditingController();
  final _brandTextController = TextEditingController();
  final _legalEntityTextController = TextEditingController();
  final _dateTextController = TextEditingController();
  final _eanTextController = TextEditingController();
  final _commercialCodeTextController = TextEditingController();

  //XFile imageFile;
  final Map<String, XFile?> _takenPictures = {};
  bool _isAuditableProduct = false;
  var _productSearchBy = ProductSearchBy.EAN;
  ReturnRequest? _existingReturnRequest;
  ProductInfo? _product;
  Future<ScreenData<void, void>>? _localData;
  late Batch _globalBatch;
  String _dateWarning = '';

  @override
  void initState() {
    super.initState();
    _globalBatch = widget.batch;
    _localData = ScreenData<void, void>().getScreenData();
  }

  @override
  Widget build(BuildContext context) {
    //final appState = Provider.of<AppState>(context, listen: false);
    final newReturnState = this;

    return FutureBuilder<ScreenData<void, void>>(
        future: _localData,
        builder: (BuildContext context,
            AsyncSnapshot<ScreenData<void, void>> snapshot) {
          Widget widget;
          if (snapshot.hasData) {
            final batch = this.widget.batch;
            _globalBatch = batch;
            widget = Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.grey,
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
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.all(15),
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
                              Container(
                                width: 45,
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.only(left: 2, right: 2),
                                child: ElevatedButton(
                                  child: const Icon(FontAwesomeIcons.barcode),
                                  onPressed: () async {
                                    if (kIsWeb) {
                                      /*final tmpFile = await getImage(1);
                                    setState(() async {
                                      imageFile = tmpFile;
                                      var fileBytes = await imageFile.readAsBytes();
                                      //print('Path: ' + imageFile.files.single.path);
                                      //metodo no soportado en Flutter web, buscar otra libreria
                                      List<BarcodeResult> results = await _barcodeReader.decodeFileBytes(fileBytes);
                                      print('Barcode: ' + results[0].toString());
                                      _controller.text = results[0].toString();
                                    });*/
                                    } else {
                                      if (Platform.isAndroid ||
                                          Platform.isIOS) {
                                        final barcode = await BarcodeScanner.scan();
                                        //setState((){
                                          _lookForProduct(barcode);
                                        //});
                                      }
                                    }
                                  },
                                ),
                              ),
                              Container(
                                width: 45,
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.only(left: 2, right: 2),
                                child: ElevatedButton(
                                  child: const Icon(// Botón Buscar
                                      FontAwesomeIcons.search),
                                  onPressed: _lookForProduct,
                                ),
                              ),
                            ],
                          ),

                          if (_product != null) ...[
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(15),
                              //child: Scaffold(
                              //body: SafeArea(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin:
                                      const EdgeInsets.only(top: 8),
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
                                          //margin: const EdgeInsets.only(top: 8),
                                          //padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                                          child: TextField(
                                            controller: _eanTextController,
                                            autofocus: true,
                                            keyboardType: TextInputType.text,
                                            textInputAction:
                                            TextInputAction.send,
                                            readOnly: true,
                                            maxLength: 30,

                                            decoration: const InputDecoration(
                                                labelText: 'EAN',
                                                border: InputBorder.none,
                                                counter: Offstage()
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          //margin: const EdgeInsets.only(top: 8),
                                          //padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                                          child: TextField(
                                            controller: _commercialCodeTextController,
                                            autofocus: true,
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
                                            //margin: const EdgeInsets.only(top: 8),
                                            //padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
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
                                            //margin: const EdgeInsets.only(top: 8),
                                            //padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
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
                                    Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
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
                                    ),
                                    if(_dateWarning != '')
                                      Icon(FontAwesomeIcons.exclamationTriangle),
                                      Text(_dateWarning,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red
                                        )),
                                    Container(
                                      margin:
                                      const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
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
                                                TextInputType.text,
                                                textInputAction:
                                                TextInputAction.send,
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
                                          SpUI.buildThumbnailsGridView(state: newReturnState, photos:  _takenPictures),
                                        ]),
                                  ]),
                              //)
                              //)
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(15),
                              child: ElevatedButton( // Botón Registrar
                                child: const Text('Registrar'),
                                onPressed: () async {
                                  try{
                                    WorkingIndicatorDialog().show(context, text: 'Registrando nueva devolución...');
                                    final thumbsWithPhotos = _takenPictures.entries
                                        .where((entry) => entry.value != null)
                                        .map((e) => MapEntry<String, String>(e.key, e.value!.path));

                                    final photosToSave = Map<String, String>.fromEntries(thumbsWithPhotos);

                                    final product = _product!;

                                    final newReturn = NewReturn(
                                      EAN: product.EAN,
                                      retailReference: _retailReferenceTextController.text,
                                      commercialCode: product.commercialCode,
                                      description: product.description,
                                      quantity: _getQuantity(),
                                      isAuditable: _isAuditableProduct,
                                      photos: photosToSave,
                                    );
                                    await BusinessServices.registerNewProductReturn(batch: batch, existingReturnRequest: _existingReturnRequest, newReturn:  newReturn);
                                    _showSnackBar('La nueva devolución fue registrada con éxito');
                                    _clearProductFields();
                                    setState(() {
                                      // Nada, para que muestre limpie el form
                                    });
                                  }
                                  on BusinessException catch(e){
                                    _showSnackBar(e.message);
                                  }
                                  catch (e){
                                    //TODO: EN GENRERAL: los errores inesperados se deben loguear o reportar al equipo de soporte atomáticamente
                                    //TODO: EN GENERAL: Detectar si los errores se deben a falta de conexión a internet, y ver como se loguean o reportan estos casos
                                    _showSnackBar('Ha ocurrido un error al guardar la nueva devolución. Error: ${e}');
                                  }
                                  finally{
                                    WorkingIndicatorDialog().dismiss();
                                  }
                                },

                              ),
                            ),
                          ],
/*            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageFile == null
                            ? AssetImage('assets/images/logo_blanco.png')
                            : FileImage(File(imageFile.path)),
                        fit: BoxFit.cover)),
              ),
            ),*/
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
        });
  }

  Future<ProductInfo> _getProductInfoByEAN(String eanCode) {
    return BusinessServices.getProductInfoByEAN(eanCode);
  }

  Future<ProductInfo> _getProductInfoByCommercialCode(String commercialCode) {
    return BusinessServices.getProductInfoByCommercialCode(commercialCode);
  }

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
        throw BusinessException('No debería haber más de una solilicitud de devolución con el mismo EAN  para productos auditables.');
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
    _retailReferenceTextController.text = '';
    _quantityTextController.text = '';
    _descriptionTextController.text = '';
    _dateTextController.text = '';
    _eanTextController.text = '';
    _commercialCodeTextController.text = '';
    _brandTextController.text = '';
    _legalEntityTextController.text = '';

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

  void _lookForProduct ([ScanResult? barcode]) async {
    try {
      // Limpiar campos
      _clearProductFields();

      if(barcode != null){
        _searchParamTextController.text = barcode.rawContent;
      }

      // Buscar info del producto y actualizar el Future del FutureBuilder.
      late ProductInfo productInfo;
      if (_productSearchBy == ProductSearchBy.EAN) {
        productInfo = await _getProductInfoByEAN(_searchParamTextController.text);
      } else {
        productInfo = await _getProductInfoByCommercialCode(_searchParamTextController.text);
      }

      // Cargar datos del producto
      _descriptionTextController.text = productInfo.description;
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      _dateTextController.text = productInfo.salesInfo  != null ? productInfo.salesInfo!.lastSellDate.toString() : '(No diponible)';
      _brandTextController.text = productInfo.brand;
      _legalEntityTextController.text = productInfo.legalEntity;
      _eanTextController.text = productInfo.EAN;
      _commercialCodeTextController.text = productInfo.commercialCode;

      if (productInfo.auditRules.photos.length == 0){
        _takenPictures['otra'] = null;
      }
      else{
        productInfo.auditRules.photos.forEach((photoAuditInfo) {
          _takenPictures[photoAuditInfo.name] = null;
        });
      }

      //TODO: Mostrar advertecia de que ya existe una solicitud con el mismo EAN en caso de que el producto NO SEA auditable
      final existingReturnRequest = await _getExistingReturnRequestInBatch(batch: _globalBatch, productInfo: productInfo);

      final dateWarning = _dateValidation(productInfo);

      setState(() {
        _isAuditableProduct = productInfo.isAuditable;
        _existingReturnRequest = existingReturnRequest;
        _product = productInfo;
        _dateWarning = dateWarning;
      });
    }
    on BusinessException catch (e) {
      _showSnackBar(
          'Error recuperando información del producto: ${e
              .message}');
    }
    on Exception catch (e) {
      _showSnackBar(
          'Ha ocurrido un error inesperado: $e');
    }
  }

  String _dateValidation(ProductInfo productInfo){

    final lastSell = productInfo.lastSell;

    if(lastSell != null && DateTime.now().difference(lastSell).inDays > 365){
      return 'La última compra fue realizada hace más de 365 días. La devolución podría ser rechazada por el auditor.';
    } else {
      return '';
    }
  }
}

enum ProductSearchBy { EAN, CommercialCode }
