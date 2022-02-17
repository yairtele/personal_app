//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_sdk/dynamsoft_barcode.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:navigation_app/router/ui_pages.dart';
import 'package:navigation_app/services/business/business_service_exception.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/services/business/product.dart';
import 'package:navigation_app/services/business/return_request.dart';
import 'package:navigation_app/ui/screen_data.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:universal_html/html.dart' as html;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter_barcode_sdk/flutter_barcode_sdk.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../app_state.dart';
import 'package:thumbnailer/thumbnailer.dart';



//FilePickerResult imageFile;
String _ruta;
var _searchParamTextController = TextEditingController();
final ImagePicker _picker = ImagePicker();
var _barcodeReader = FlutterBarcodeSdk();

var _loadReturn;
var _quantity;


var type;

class NewReturn extends StatefulWidget {
  final ReturnRequest returnRequest;
  const NewReturn({Key key, this.returnRequest}) : super(key: key);

  @override
  State<NewReturn> createState() => _NewReturn();
}

class _NewReturn extends State<NewReturn> {
  XFile _quantityImage;
  XFile imageFile;
  final Map<String, XFile> _takenPictures = {};
  bool _isAuditableProduct = false;
  var _productSearchBy = ProductSearchBy.EAN;
  Product _product = null;
  Future<ScreenData<void, void>> _localData;

  String _currentProductSearchParam = null;

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
                                      onChanged: (value) {
                                        setState(() {
                                          _currentProductSearchParam =
                                              _searchParamTextController.text;
                                        });
                                      },
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
                                  child: const Icon(
                                      FontAwesomeIcons.search),
                                  onPressed: () async {
                                    try {
                                      // Buscar info del producto y actualizar el Future del FutureBuilder.
                                      Product product = null;
                                      if (_productSearchBy ==
                                          ProductSearchBy.EAN) {
                                        product = await _getProductByEAN(_currentProductSearchParam);
                                      } else {
                                        product = await _getProductByCommercialCode(_currentProductSearchParam);
                                      }

                                      _takenPictures.clear();

                                      if (product.photos.length == 0){
                                        _takenPictures['Foto'] = null;
                                      }
                                      else{
                                        product.photos.forEach((photoName) {
                                          _takenPictures[photoName] = null;
                                        });
                                      }

                                      setState(() {
                                        _isAuditableProduct = product.photos.length > 0;
                                        _product = product;
                                      });
                                    }
                                    on BusinessServiceException catch (e) {
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
                                          autofocus: true,
                                          keyboardType:
                                          TextInputType.text,
                                          textInputAction:
                                          TextInputAction.send,
                                          maxLength: 30,
                                          decoration: const InputDecoration(
                                              labelText:
                                              'Referencia interna',
                                              helperText:
                                              'Ej: AEF54216CV'),
                                          onChanged: (value) {
                                            //_quantity = value;
                                          }
                                        //},
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
                                                onChanged: (value) {
                                                  _quantity = value;
                                                }
                                              //},
                                            ),
                                          ),
                                          _buildThumbnailsGridView(pictures:  _takenPictures),
                                        ]),
                                  ]),
                              //)
                              //)
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(15),
                              child: ElevatedButton(
                                onPressed: () =>
                                appState.currentAction =
                                    PageAction(
                                        state: PageState.pop,
                                        page: NewBatchPageConfig),
                                //devolver a new batch anterior
                                child: const Text('Confirmar'),
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

  Future<Product> _getProductByEAN(String eanCode) {
    return BusinessServices.getProductByEAN(eanCode);
  }

  Future<Product> _getProductByCommercialCode(String commercialCode) {
    return BusinessServices.getProductByCommercialCode(commercialCode);
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

  Widget _buildThumbnailsGridView({@required Map<String, XFile> pictures}) {

    return GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        shrinkWrap: true,
        children: <Widget>[
          for(final photoName in  pictures.keys)
            _buildPhotoThumbnail(photoName, pictures)
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
}

Future getImage(int type) async {
  final pickedImage = await ImagePicker().getImage(
      source: type == 1 ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 50);
  return pickedImage;
}


enum ProductSearchBy { EAN, CommercialCode }
