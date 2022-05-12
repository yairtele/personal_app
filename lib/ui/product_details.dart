import 'dart:io';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/batch_states.dart';
import 'package:navigation_app/services/business/business_exception.dart';
import 'package:navigation_app/services/business/photo_detail.dart';
import 'package:navigation_app/services/business/product.dart';
import 'package:navigation_app/services/business/product_detail.dart';
import 'package:navigation_app/services/business/product_info.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/ui/screen_data.dart';
import 'package:navigation_app/utils/sp_asset_utils.dart';
import 'package:navigation_app/utils/sp_product_utils.dart';
import 'package:navigation_app/utils/ui/sp_ui.dart';
import 'package:navigation_app/utils/ui/thumb_photo.dart';
import 'package:navigation_app/utils/ui/working_indicator_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_state.dart';
import '../router/ui_pages.dart';

class  ProductDetails extends StatefulWidget {
  final Product product;
  final Batch batch;
  const ProductDetails({Key? key, required this.product,required this.batch}) : super(key: key);

  @override
  _ProductDetailsState createState() =>  _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late Future<ScreenData<Product, ProductDetail>> _localData;
  ProductInfo? _productInfo;
  //Map<String, PhotoDetail> _takenPictures = {};
  Map<String, ThumbPhoto> _takenPictures = {};
  var _referenceModified = false;
  //final _modifiedPhotos =  ProductPhotos([]);
  late XFile _dummyPhoto;
  var _reference;

  @override
  void initState(){
    super.initState();
    _localData = ScreenData<Product, ProductDetail>(dataGetter: _getProductDetail).getScreenData(dataGetterParam: widget.product);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    var enabled_value = true;
    final product = widget.product;
    final newProductDetailsState = this;
    final _batch = widget.batch;
    if (_batch.state != BatchStates.Draft) {
      enabled_value = false;
    }
    if(!_referenceModified){
      final reference = product.retailReference;
      _reference = TextEditingController(text: reference);
    }

    return WillPopScope(
        onWillPop: () {
          appState.returnWith(false);

          //we need to return a future
          return Future.value(false);
        },
        child: FutureBuilder<ScreenData<Product, ProductDetail>>(
            future: _localData,
            builder: (BuildContext context,
                AsyncSnapshot<ScreenData<Product, ProductDetail>> snapshot) {
              Widget widget;
              if (snapshot.hasData) {
                final data = snapshot.data!;
                _takenPictures = data.data!.productPhotos;
                _productInfo = data.data!.productInfo;
                final EAN = product.EAN;
                final _EAN = TextEditingController(text: EAN);
                final descripcion = product.description;
                final _descripcion = TextEditingController(text: descripcion);

                //List<String> _modifiedPhotos = [];

                widget = Scaffold(
                    appBar: AppBar(
                      elevation: 0,
                      backgroundColor: Colors.grey,
                      title: Text(
                        'Producto ${product.retailReference}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      actions: [
                        /*IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () =>
                          appState.currentAction =
                              PageAction(state: PageState.addPage,
                                  pageConfig: SettingsPageConfig),
                        ),*/
                        if (_batch.state == BatchStates.Draft)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey,
                            ),
                            onPressed: () {
                              launch(
                                  'https://newsan.athento.com/accounts/login/?next=/dashboard/');
                            }
                            , icon: Image.asset(
                            'assets/images/boton_athento.png',
                            height: 40.0, width: 40.0,),
                            label: const Text(''),
                          ),
                      ],
                    ),
                    body: SafeArea(
                        child: ListView(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(15),
                                child: TextField(
                                  autofocus: true,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.send,
                                  maxLength: 30,
                                  enabled: false,
                                  controller: _EAN,
                                  decoration: const InputDecoration(
                                    hintText: '-',
                                    label: Text.rich(
                                        TextSpan(
                                          children: <InlineSpan>[
                                            WidgetSpan(
                                              child: Text(
                                                  'EAN:', style: TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        )
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(15),
                                child: TextField(
                                  autofocus: true,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.send,
                                  maxLength: 50,
                                  enabled: false,
                                  controller: _descripcion,
                                  decoration: const InputDecoration(
                                    hintText: '-',
                                    label: Text.rich(
                                        TextSpan(
                                          children: <InlineSpan>[
                                            WidgetSpan(
                                              child: Text(
                                                  'Descripcion:',
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight: FontWeight
                                                          .bold)),
                                            ),
                                          ],
                                        )
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child:
                                        Container(
                                            margin: const EdgeInsets.only(top: 8),
                                            padding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
                                            child: TextField(
                                              autofocus: true,
                                              keyboardType: TextInputType.text,
                                              textInputAction: TextInputAction.send,
                                              maxLength: 50,
                                              enabled: enabled_value,
                                              controller: _reference,
                                              onChanged: (_) {
                                                _referenceModified = true;
                                              },
                                              decoration: const InputDecoration(
                                                hintText: '-',
                                                label: Text.rich(
                                                    TextSpan(
                                                      children: <InlineSpan>[
                                                        WidgetSpan(
                                                          child: Text(
                                                              'Referencia:',
                                                              style: TextStyle(
                                                                  fontSize: 18.0,
                                                                  fontWeight: FontWeight
                                                                      .bold)),
                                                        ),
                                                      ],
                                                    )
                                                ),
                                              ),
                                            ),
                                          )
                                      ),
                                  Container(
                                    width: 45,
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.only(right: 10),
                                    child: ElevatedButton(
                                      child: const Icon(FontAwesomeIcons.barcode),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.only(left: 0, right: 0),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
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
                                          if (Platform.isAndroid || Platform.isIOS) {
                                            FocusManager.instance.primaryFocus?.unfocus();
                                            final barcode = await BarcodeScanner.scan();
                                            setState(() {
                                              _reference.text = barcode.rawContent;
                                              _referenceModified = true;
                                            });
                                          }
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                //child: SpUI.buildProductThumbnailsGridView(state: newProductDetails, photos:  _takenPictures, context: context, modifiedPhotos: _modifiedPhotos,batch: _batch)
                                  child: SpUI.buildThumbnailsGridView(
                                      state: newProductDetailsState,
                                      photos: _takenPictures,
                                      dummyPhoto: _dummyPhoto,
                                      photoParentState: product.state!)
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        if (product.state ==
                                            BatchStates.Draft || product
                                            .state == BatchStates.InfoPendiente)
                                          ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  WorkingIndicatorDialog().show(
                                                      context,
                                                      text: 'Actualizando producto...');
                                                  await _updateProduct(
                                                      _referenceModified,
                                                      _reference.text,
                                                      _takenPictures, product);

                                                  appState.returnWith(true);

                                                  _showSnackBar(
                                                      'Producto actualizado con éxito');
                                                }
                                                on BusinessException catch (e) {
                                                  _showSnackBar(e.message);
                                                }
                                                on Exception catch (e) {
                                                  _showSnackBar(
                                                      'Ha ocurrido un error inesperado al actualizar el producto: $e');
                                                }
                                                finally {
                                                  WorkingIndicatorDialog()
                                                      .dismiss();
                                                }
                                              },
                                              child: const Text('Guardar'),
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.green[400],
                                              )
                                          ),
                                        if (product.state == BatchStates.Draft)
                                          ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  WorkingIndicatorDialog().show(
                                                      context,
                                                      text: 'Eliminando producto...');
                                                  await _deleteProduct(product);
                                                  appState.returnWith(true);
                                                  _showSnackBar(
                                                      'Producto eliminado con éxito');
                                                }
                                                on BusinessException catch (e) {
                                                  _showSnackBar(e.message);
                                                }
                                                on Exception catch (e) {
                                                  _showSnackBar(
                                                      'Ha ocurrido un error inesperado al eliminar el producto: $e');
                                                }
                                                finally {
                                                  WorkingIndicatorDialog()
                                                      .dismiss();
                                                }
                                              },
                                              child: const Text('Eliminar'),
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.red[400],
                                              )
                                          )
                                      ]
                                  )
                              )
                            ]
                        )));
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
                    child: Stack(
                        children: <Widget>[
                          const Opacity(
                            opacity: 1,
                            child: CircularProgressIndicator(
                                backgroundColor: Colors.grey),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('Cargando...', style: TextStyle(
                                color: Colors.grey, height: 4, fontSize: 9)),
                          )
                        ]
                    )
                );
              }
              return widget;
            }
        )
    );
  }

  Future<ProductDetail> _getProductDetail(Product? product) async {
    _dummyPhoto = await SpAssetUtils.getImageXFileFromAssets('images/img_not_found.jpg');
    _productInfo = await BusinessServices.getProductInfoByEAN(product!.EAN);
    final productExistingPhotos = await BusinessServices.getPhotosByProductUUID(product.uuid!);
    //final productPhotos = (await _getFullPhotosInfo(productExistingPhotos))
    //  .map((key, photoDetail) => MapEntry(key, ThumbPhoto(uuid: photoDetail.uuid, photo: photoDetail.content!, isDummy: photoDetail.isDummy)));
    final productPhotos = productExistingPhotos
      .map((key, photoDetail) => MapEntry(
        key,
        ThumbPhoto(
          uuid: photoDetail.uuid,
          photo: photoDetail.content,
          isDummy: photoDetail.isDummy,
          hasChanged: false,
          state: photoDetail.state!
        )
      )
    );

    return ProductDetail(productInfo: _productInfo!, productPhotos: productPhotos);
  }

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _doesNotContainPhoto(Map<String,PhotoDetail> existingPhotos, String photoName){
    return !existingPhotos.containsKey(photoName);
  }

  /*
  Future<Map<String,PhotoDetail>> _getFullPhotosInfo(Map<String, PhotoDetail> existingPhotoDetails) async {

      //var existingPhotos = _getPhotoContents(existingPhotoDetails);

      if (_productInfo!.auditRules.photos.length == 0 && !existingPhotoDetails.containsKey('otra')){
        existingPhotoDetails['otra'] = PhotoDetail(uuid: null, content: null);
      }
      else{
        final missingPhotos = _productInfo!.auditRules.photos.where((p) => _doesNotContainPhoto(existingPhotoDetails, p.name)).toList();

        for(final photoAuditInfo in missingPhotos){
          existingPhotoDetails[photoAuditInfo.name] = PhotoDetail(uuid: null, content: null);
        }
      }

      return existingPhotoDetails;
  }
*/
/*  Map<String, XFile?> _getPhotoContents(Map<String, PhotoDetail> photoDetails) {
    var photos = <String, XFile?>{};

    for (var key in photoDetails.keys){
      photos[key] = photoDetails[key]!.content;
    }

    return photos;
  }*/

  Future<void> _updateProduct(bool referenceModified, String reference,  Map<String, ThumbPhoto> photos, Product product) async {
    //final changedPhotos = photos.entries.where((element) => element.value.hasChanged == true);

    //final photosToUpdate = Map<String, ThumbPhoto>.fromEntries(changedPhotos)
    final photosToUpdate = photos
        .map((key, thumbPhoto) => MapEntry(
        key,
        PhotoDetail(
          uuid: thumbPhoto.uuid!,
          content: thumbPhoto.photo,
          isDummy: thumbPhoto.isDummy,
          state: thumbPhoto.state,
          hasChanged: thumbPhoto.hasChanged
        )
      )
    );
    await BusinessServices.updateProduct(referenceModified, reference,  photosToUpdate, product);
  }

  Future <void> _deleteProduct(Product product) async {
    await BusinessServices.deleteProductByUUID(product.uuid!);
  }
}