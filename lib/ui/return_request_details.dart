import 'dart:io';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/batch_states.dart';
import 'package:navigation_app/services/business/business_exception.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/services/business/photo_detail.dart';
import 'package:navigation_app/services/business/product.dart';
import 'package:navigation_app/services/business/return_request.dart';
import 'package:navigation_app/services/business/return_request_detail.dart';
import 'package:navigation_app/ui/ui_helper.dart';
import 'package:navigation_app/utils/sp_asset_utils.dart';
import 'package:navigation_app/utils/ui/sp_ui.dart';
import 'package:navigation_app/ui/product_details.dart';
import 'package:navigation_app/ui/screen_data.dart';
import 'package:navigation_app/utils/ui/thumb_photo.dart';
import 'package:navigation_app/utils/ui/working_indicator_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_state.dart';
import '../router/ui_pages.dart';
import 'newreturn.dart';

class  ReturnRequestDetails extends StatefulWidget {
  final ReturnRequest returnRequest;
  final Batch batch;
  const ReturnRequestDetails({Key? key, required this.batch, required this.returnRequest}) : super(key: key);

  @override
  _ReturnRequestDetailsState createState() =>  _ReturnRequestDetailsState();
}

class  _ReturnRequestDetailsState extends State<ReturnRequestDetails> {
  late Future<ScreenData<String, ReturnRequestDetail>> _localData;
  bool _shouldRefreshParent = false;
  Map<String, ThumbPhoto> _takenPictures = {};
  late XFile _dummyPhoto;
  var _referenceModified = false;
  var _reference;

  @override
  void initState() {
    super.initState();
    _localData = getScreenData();
  }

  Future<ScreenData<String, ReturnRequestDetail>> getScreenData() {
    return ScreenData<String, ReturnRequestDetail>(dataGetter: _getReturnRequestDetail)
      .getScreenData(dataGetterParam: widget.returnRequest.uuid);
  }

  @override
  Widget build(BuildContext context) {
    var enabled_value=true;
    final appState = Provider.of<AppState>(context, listen: false);
    final returnRequest = widget.returnRequest;
    final newReturnRequestDetailsState = this;

    final _batch = widget.batch;
    if (_batch.state!=BatchStates.Draft){
      enabled_value = false;
    }

    return WillPopScope(
      onWillPop: () {
        appState.returnWith(_shouldRefreshParent);
        _shouldRefreshParent = false;
        //we need to return a future
        return Future.value(false);
      },
      child: FutureBuilder<ScreenData<String, ReturnRequestDetail>>(
          future: _localData,
          builder: (BuildContext context,
              AsyncSnapshot<ScreenData<String, ReturnRequestDetail>> snapshot) {
            Widget widget;
            if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
              final data = snapshot.data!;
              final shouldShowStateColumn = returnRequest.state != 'Draft';
              _takenPictures = data.data!.optionalPhotos;
              final products = data.data!.products;
              if(!_referenceModified){
                final reference = returnRequest.retailReference;
                _reference = TextEditingController(text: reference);
              }
              final _eanTextController = TextEditingController(
                  text: returnRequest.EAN);
              final _skuTextController = TextEditingController(
                  text: returnRequest.sku);
              final _commercialCodeTextController = TextEditingController(
                  text: returnRequest.commercialCode);
              var cantidad = returnRequest.quantity;
              if (cantidad == null) {
                cantidad = 1;
              }
              final _cantidad = TextEditingController(text: cantidad.toString());
              final descripcion = returnRequest.description;
              final _descripcion = TextEditingController(text: descripcion);
              widget = Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: const Color(0xFF741526),//Colors.grey,
                  title: Text(
                    returnRequest.retailReference ??
                        returnRequest.requestNumber ?? 'Generando N° Solicitud...',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  actions: [
                    /*
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () =>
                      appState.currentAction =
                          PageAction(
                              state: PageState.addPage, pageConfig: SettingsPageConfig),
                    ),*/
                    if (_batch.state==BatchStates.Draft)
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => //TODO: ver si se debe poder realizar una nueva devolución para los EAN no autitables, o cómo precargar los datos en la pantalla NewReturn
                      appState.waitCurrentAction<bool>(
                          PageAction(state: PageState.addWidget,
                              widget: NewReturnScreen(batch: this.widget.batch, returnRequest: this.widget.returnRequest),
                              pageConfig: NewReturnPageConfig))
                      .then((shouldRefresh) {
                        if(shouldRefresh!){
                          setState(() {
                            _shouldRefreshParent = shouldRefresh; //TODO: analizar bien esto
                            _localData = getScreenData();
                          });
                        }
                      }),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF741526)//Colors.grey,
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
                        //margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.fromLTRB(15,0,15,0),//all(15),
                        child: TextField(
                          //enabled: false,
                          autofocus: false,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.send,
                          maxLength: 50,
                          controller: _eanTextController,
                          enabled: false,
                          decoration: const InputDecoration(
                            hintText: 'EAN',
                            label: Text.rich(
                                TextSpan(
                                  children: <InlineSpan>[
                                    WidgetSpan(
                                      child: Text(
                                          'EAN:',
                                          style: TextStyle(fontSize: 18.0,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                )
                            ),
                          ),
                        ),
                      ),
                      Container(
                        //margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.fromLTRB(15,0,15,0),//all(15),
                        child: TextField(
                          //enabled: false,
                          autofocus: false,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.send,
                          maxLength: 50,
                          controller: _skuTextController,
                          enabled: false,
                          decoration: const InputDecoration(
                            hintText: 'Código de inventario',
                            label: Text.rich(
                                TextSpan(
                                  children: <InlineSpan>[
                                    WidgetSpan(
                                      child: Text(
                                          'SKU:',
                                          style: TextStyle(fontSize: 18.0,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                )
                            ),
                          ),
                        ),
                      ),
                      Container(
                        //margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.fromLTRB(15,0,15,0),//all(15),
                        child: TextField(
                          autofocus: false,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.send,
                          maxLength: 50,
                          controller: _commercialCodeTextController,
                          enabled: false,
                          decoration: const InputDecoration(
                            hintText: 'Código Comercial',
                            label: Text.rich(
                                TextSpan(
                                  children: <InlineSpan>[
                                    WidgetSpan(
                                      child: Text(
                                          'Código Comercial:',
                                          style: TextStyle(fontSize: 18.0,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                )
                            ),
                          ),
                        ),
                      ),
                      if(!returnRequest.isAuditable)
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                              //margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.fromLTRB(15,0,15,0),//all(15),
                              child: TextField(
                                enabled: enabled_value,
                                autofocus: false,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.send,
                                maxLength: 50,
                                controller: _reference,
                                onChanged: (_) {
                                  _referenceModified = true;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Referencia Interna',
                                  label: Text.rich(
                                      TextSpan(
                                        children: <InlineSpan>[
                                          WidgetSpan(
                                            child: Text(
                                                'Referencia Interna:',
                                                style: TextStyle(fontSize: 18.0,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      )
                                  ),
                                ),
                              ),
                            )
                            ),
                            if (_batch.state==BatchStates.Draft)
                              Container(
                              width: 45,
                              //margin: const EdgeInsets.only(top: 8),
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
                        //margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.fromLTRB(15,0,15,0),//all(15),
                        child: TextField(
                          enabled: false,
                          autofocus: false,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.send,
                          maxLength: 50,
                          controller: _descripcion,
                          decoration: const InputDecoration(
                            hintText: 'Descripcion',
                            label: Text.rich(
                                TextSpan(
                                  children: <InlineSpan>[
                                    WidgetSpan(
                                      child: Text(
                                          'Descripcion:', style: TextStyle(
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
                        //margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.fromLTRB(15,0,15,0),//all(15),
                        child: TextField(
                          enabled: enabled_value && !returnRequest.isAuditable,
                          autofocus: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                          textInputAction: TextInputAction.send,
                          maxLength: 4,
                          controller: _cantidad,
                          decoration: const InputDecoration(
                            hintText: 'Unidades',
                            counterText: '',
                            label: Text.rich(
                                TextSpan(
                                  children: <InlineSpan>[
                                    WidgetSpan(
                                      child: Text(
                                          'Unidades:', style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                )
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //TODO: chequear estado de la solicitud y no del lote.
                            if (returnRequest.isAuditable == false && (returnRequest.state==BatchStates.Draft || returnRequest.state==BatchStates.InfoPendiente))
                            ElevatedButton(
                              onPressed: () async {
                                try{
                                  WorkingIndicatorDialog().show(context, text: 'Actualizando Solicitud...');
                                  await _updateReqReturn(returnRequest,_eanTextController.text,_reference.text,_descripcion.text,_cantidad.text, _takenPictures);
                                  appState.returnWith(true);
                                  //_shouldRefreshParent = true;
                                  _showSnackBar('Solicitud actualizada con éxito');
                                }
                                on BusinessException catch (e){
                                  _showSnackBar(e.message);
                                }
                                on Exception catch (e){
                                  _showSnackBar('Ha ocurrido un error inesperado al actualizar la solicitud: $e');
                                }
                                finally{
                                  WorkingIndicatorDialog().dismiss();
                                }
                              },

                              child: const Icon(FontAwesomeIcons.save),//Text('Guardar'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green[400],
                              )
                          ),
                            if (_batch.state==BatchStates.Draft)
                            ElevatedButton(
                                onPressed: () async {
                                  showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: const Text('Alerta'),
                                      content: const Text('¿Seguro quiere eliminar esta Solicitud?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => { Navigator.of(context).pop() },
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                            child: const Text('Borrar'),
                                            onPressed: () async {
                                              try {
                                                WorkingIndicatorDialog().show(
                                                    context,
                                                    text: 'Eliminando Solicitud...');
                                                await _deleteReqReturn(returnRequest);
                                                _showSnackBar('La Solicitud ha sido eliminada exitosamente');
                                                appState.returnWith(true);
                                              }
                                              on BusinessException catch (e){
                                                _showSnackBar(e.message);
                                              }
                                              on Exception catch (e){
                                                _showSnackBar('Ha ocurrido un error inesperado eliminando la solicitud: $e');
                                              }
                                              finally{
                                                WorkingIndicatorDialog().dismiss();
                                              }
                                            }
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Icon(FontAwesomeIcons.trash),//Text('Borrar Solicitud'),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                )
                            ),
                          ],
                        ),
                      ),
                      if(returnRequest.isAuditable)
                        DataTable(
                        columns: <DataColumn>[
                          const DataColumn(
                            label: Text('Productos:'),
                          ),
                          if(shouldShowStateColumn)
                            const DataColumn(label: Text('Estado'))
                        ],
                        rows: List<DataRow>.generate(
                          products.length,
                              (int index) =>
                              DataRow(
                                color: UIHelper.getAuditItemBackgroundColor(products[index].state!),
                                cells: <DataCell>[DataCell(
                                    ListTile(isThreeLine: true,
                                      leading: const Icon(Icons.workspaces_filled,
                                        color: Colors.grey,),
                                      title: Text(
                                          'Ref: ${products[index].retailReference ??
                                              '(sin referencia interna)' }'),
                                      subtitle: const Text(''),
                                    ), onTap: () {
                                  appState.waitCurrentAction<bool>(PageAction(
                                      state: PageState.addWidget,
                                      widget: ProductDetails(
                                          product: products[index],
                                          batch: this.widget.batch),
                                      pageConfig: DetailProductPageConfig))
                                      .then((shouldRefresh) {
                                    setState(() {
                                      if (shouldRefresh!) { //TODO: meter el if fuera del setstate
                                        _shouldRefreshParent =
                                            shouldRefresh; //TODO: analizar bien esto
                                        _localData = getScreenData();
                                      }
                                    });
                                  });
                                }),
                                if(shouldShowStateColumn)
                                  DataCell(Text(products[index].state!))
                              ],
                            ),
                        ),
                        )
                    else
                      Container(
                        //child: SpUI.buildReturnRequestThumbnailsGridView(state: newReturnRequestDetails, photos:  _takenPictures, context: context, modifiedPhotos: _modifiedPhotos,batch:_batch)
                          child: SpUI.buildThumbnailsGridView(state: newReturnRequestDetailsState, photos:  _takenPictures, dummyPhoto: _dummyPhoto, photoParentState: returnRequest.state!)

                      )
                    ],
                  ),
                ),
              );
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
      ),
    );

  }

  Future<ReturnRequestDetail> _getReturnRequestDetail(String? returnRequestUUID) async {
    _dummyPhoto = await SpAssetUtils.getImageXFileFromAssets('images/img_not_found.jpg');

    final products = await _getProducts(returnRequestUUID);
    final optionalPhotos = await _getOptionalPhoto(returnRequestUUID);
    final returnPhotos = optionalPhotos
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
    return ReturnRequestDetail(products: products, optionalPhotos: returnPhotos);
  }

  Future<List<Product>> _getProducts(String? returnRequestUUID) async {
    final products = await BusinessServices.getProductsByReturnRequestUUID(
        returnRequestUUID!);

    return products;
  }

  Future<void> _deleteReqReturn(ReturnRequest req_return) async {
    await BusinessServices.deleteReqReturnByUUID(req_return.uuid!);
  }

  Future<void> _updateReqReturn(ReturnRequest req_return, String EAN,
      String reference, String description, String unities, Map<String, ThumbPhoto> photos) async {

    final changedPhotos = photos.entries.where((element) => element.value.hasChanged == true);

    final photosToUpdate = Map<String, ThumbPhoto>.fromEntries(changedPhotos)
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
    await BusinessServices.updateReqReturn(
        req_return, EAN, reference, description, unities, photosToUpdate);
  }

  Future<Map<String,PhotoDetail>> _getOptionalPhoto(returnRequestUUID) async {
    return BusinessServices.getPhotosByProductUUID(returnRequestUUID);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

