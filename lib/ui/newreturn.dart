//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/business_exception.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/services/business/new_return.dart';
import 'package:navigation_app/services/business/product_info.dart';
import 'package:navigation_app/services/business/return_request.dart';
import 'package:navigation_app/ui/screen_data.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../app_state.dart';




var type;

class NewReturnScreen extends StatefulWidget {
  final ReturnRequest returnRequest;
  final Batch batch;
  const NewReturnScreen({Key key, @required this.batch, this.returnRequest}) : super(key: key);

  @override
  State<NewReturnScreen> createState() => _NewReturnScreenState();
}

class _NewReturnScreenState extends State<NewReturnScreen> {
  final _searchParamTextController = TextEditingController();
  final _retailReferenceTextController = TextEditingController();
  final _quantityTextController = TextEditingController();


  XFile imageFile;
  final Map<String, XFile> _takenPictures = {};
  bool _isAuditableProduct = false;
  var _productSearchBy = ProductSearchBy.EAN;
  ReturnRequest _existingReturnRequest = null;
  ProductInfo _product = null;
  Future<ScreenData<void, void>> _localData;

  @override
  void initState() {
    super.initState();

    _localData = ScreenData<void, void>().getScreenData();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return FutureBuilder<ScreenData<void, void>>(
        future: _localData,
        builder: (BuildContext context,
            AsyncSnapshot<ScreenData<void, void>> snapshot) {
          Widget widget;
          if (snapshot.hasData) {
            final batch = this.widget.batch;
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
                                        _productSearchBy = value;
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
                                        _productSearchBy = value;
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
                                        setState(() async {
                                          final barcode =
                                          await BarcodeScanner.scan();
                                          _searchParamTextController.text =
                                              barcode.rawContent;
                                        });
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
                                  onPressed: () async {
                                    try {
                                      // Buscar info del producto y actualizar el Future del FutureBuilder.
                                      ProductInfo productInfo = null;
                                      if (_productSearchBy ==
                                          ProductSearchBy.EAN) {
                                        productInfo = await _getProductInfoByEAN(_searchParamTextController.text);
                                      } else {
                                        productInfo = await _getProductInfoByCommercialCode(_searchParamTextController.text);
                                      }

                                      _clearProductFields();

                                      if (productInfo.photos.length == 0){
                                        _takenPictures['otra'] = null;
                                      }
                                      else{
                                        productInfo.photos.forEach((photoName) {
                                          _takenPictures[photoName] = null;
                                        });
                                      }

                                      //TODO: Mostrar advertecia de que ya existe una siolicitud con el mismo EAN en caso de que el producto NO SEA auditable
                                      final existingReturnRequest = await _getExistingReturnRequestInBatch(batch: batch, productInfo: productInfo);

                                      setState(() {
                                        _isAuditableProduct = productInfo.isAuditable;
                                        _existingReturnRequest = existingReturnRequest;
                                        _product = productInfo;
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
                                  },
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
                                    Text(
                                      'Descripcion: ${_product.description}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                    Container(
                                      margin:
                                      const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.all(30),
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
                                          _buildThumbnailsGridView(photos:  _takenPictures),
                                        ]),
                                  ]),
                              //)
                              //)
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(15),
                              child: ElevatedButton(
                                child: const Text('Confirmar'),
                                onPressed: () async {
                                  try{

                                    final thumbsWithPhotos = _takenPictures.entries
                                        .where((entry) => entry.value != null)
                                        .map((e) => MapEntry<String, String>(e.key, e.value.path));

                                    final photosToSave = Map<String, String>.fromEntries(thumbsWithPhotos);

                                    final newReturn = NewReturn(
                                      EAN: _product.EAN,
                                      retailReference: _retailReferenceTextController.text,
                                      commercialCode: _product.commercialCode,
                                      description: _product.description,
                                      quantity: _getQuantity(),
                                      isAuditable: _isAuditableProduct,
                                      photos: photosToSave,
                                    );
                                    await BusinessServices.registerNewProductReturn(batch: batch, existingReturnRequest: _existingReturnRequest, newReturn:  newReturn);
                                  }
                                  on BusinessException catch(e){
                                    _showSnackBar(e.message);
                                  }
                                  on Exception catch(e){
                                    //TODO: EN GENRERAL: los errores inesperados se deben loguear o reportar al equipo de soporte atomáticamente
                                    //TODO: EN GENERAL: Detectar si los errores se deben a falta de conexión a internet, y ver como se loguean o reportan estos casos
                                    _showSnackBar('Ha ocurrido un error al guardar la nueva devolución. Error: ${e}');
                                  }
                                  catch (e){
                                    final pepe = e;
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
                          ListTile(
                              leading: const Icon(
                                FontAwesomeIcons.barcode,
                              ),
                              onTap: () async {
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
                                  if (Platform.isAndroid || Platform.isIOS) {
                                    setState(() async {
                                      final barcode = await BarcodeScanner.scan();
                                      _searchParamTextController.text = barcode.rawContent;
                                    });
                                  }
                                }
                              }),
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

  Future<XFile> _getPhotoFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    return pickedFile;
  }

  Widget _buildThumbnailsGridView({@required Map<String, XFile> photos}) {

    return GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        shrinkWrap: true,
        children: <Widget>[
          for(final photoName in  photos.keys)
            _buildPhotoThumbnail(photoName, photos)
        ]
    );
  }

  Widget _buildPhotoThumbnail(String photoName, Map<String, XFile> photos) {
    final photo = photos[photoName];

    return Container(
        padding: const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 0),
        decoration: BoxDecoration(
            border: Border.all(
                color: Colors.blueGrey, width: 1, style: BorderStyle.solid)
        ),
        child: Column(
          children: [
            Expanded( // Show photo or icon
                child: ((){
                  if (photo != null)
                    return  Image.file(File(photo.path));
                  else
                    return const Icon(FontAwesomeIcons.camera);
                })()
            ),
            Row(
              children: [
                Expanded(child: Text(photoName, textAlign: TextAlign.center)), // Photo name
                if(photo != null)
                  ElevatedButton( // Delete photo
                    child: const Icon(FontAwesomeIcons.trash),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.all(4),
                    ),
                    onPressed: () async {
                      //TODO: ver si se debe borrar el archivo donde estaba la foto
                      setState(() {
                        photos[photoName] = null;
                      });
                    },
                  )
                else
                  ElevatedButton( // Take photo
                    child: const Icon(FontAwesomeIcons.camera),
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.all(4),
                    ),
                    onPressed: () async {
                      final pickedPhoto = await _getPhotoFromCamera();
                      setState(() {
                        photos[photoName] = pickedPhoto;
                      });
                    },
                  )
              ],
            )
          ],
        )
    );
  }

  Future<ReturnRequest> _getExistingReturnRequestInBatch({Batch batch, ProductInfo productInfo}) async {
    ReturnRequest existingReturnRequest;
    // Buscar todas las solicitudes del batch.
    final returnRequests = await BusinessServices.getReturnRequestsByBatchNumber(batchNumber: batch.batchNumber);

    // Si no hay ninguna, retornar null
    if(returnRequests.length == 0){
      return null;
    }



    if (productInfo.isAuditable == true){
      // Entre las existentes, buscar las que tienen el mismo EAN que el producto a devolver
      final returnRequestsWithSameEAN = returnRequests.where((returnRequest) => returnRequest.EAN == productInfo.EAN);
      if(returnRequestsWithSameEAN.length > 1){
        throw BusinessException('No debería haber más de una solilicitud de devolución con el mismo EAN  para productos auditables.');
      }
      existingReturnRequest = returnRequestsWithSameEAN.first;
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
    _takenPictures.clear();
  }

  int _getQuantity() {
    int quantity = null;

    if(!_product.isAuditable) {
      quantity = int.tryParse(_quantityTextController.text);
      if(quantity == null || quantity <= 0){
        throw BusinessException('Por favor indique la cantidad a devolver. No puede ser cero ni vacía.');
      }
    }
    return quantity;
  }
}

Future getImage(int type) async {
  final pickedImage = await ImagePicker().getImage(
      source: type == 1 ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 50);
  return pickedImage;
}


enum ProductSearchBy { EAN, CommercialCode }
