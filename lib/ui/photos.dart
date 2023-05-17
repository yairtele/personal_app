import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:marieyayo/services/business/batch.dart';
import 'package:marieyayo/services/sp_ws/web_service_exception.dart';
import 'package:marieyayo/ui/screen_data.dart';
import 'package:marieyayo/ui/ui_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../config/cache.dart';
import '../config/configuration.dart';
import '../router/ui_pages.dart';
import '../utils/photos_utils.dart';
import '../utils/sp_file_utils.dart';
import '../utils/ui/sp_ui.dart';
import '../services/drive_api.dart';

class Photos extends StatefulWidget{
  const Photos({Key? key}) : super(key: key);

  @override
  _PhotosState createState() => _PhotosState();
}

class _PhotosState extends State<Photos> {

  late List<Image> _photos;
  Image? _selectedPhoto = null;
  late Future<ScreenData<void, bool>> _localData;
  late String _userPhoto;

  @override
  void initState(){
    super.initState();
    _localData =  _getScreenData();
  }

  Future<ScreenData<void, bool>> _getScreenData() => ScreenData<void, bool>(dataGetter: _getPhotos).getScreenData();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final photosState = this;

    if(getLoginStatus()){
      return FutureBuilder<ScreenData<void, bool>>(

          future: _localData,
          builder: (BuildContext context, AsyncSnapshot<ScreenData<dynamic, bool>> snapshot) {

            Widget widget;
            if (snapshot.connectionState == ConnectionState.done &&  snapshot.hasData) {
              final data = snapshot.data!;
              final userInfo = data.userInfo;

              widget = Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Configuration.customerPrimaryColor,
                    title: const Text(
                      '',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Configuration.customerSecondaryColor),
                    ),
                    actions: [
                      IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () =>
                              appState.waitCurrentAction<bool>(
                                  PageAction(state: PageState.addPage,
                                      pageConfig: NewBatchPageConfig)
                              ).then((shouldRefresh) {
                                if (shouldRefresh!) {
                                  setState(() {
                                    _localData = _getScreenData();
                                  });
                                }
                              })
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            primary: Configuration.customerPrimaryColor
                        ),
                        onPressed: () {
                          //TODO: PAPP - Mostrar notita de alerta con info del user logueado
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                title: const Text('Alerta'),
                                content: const Text('¿Cerrar sesión?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => { Navigator.of(context).pop() },
                                    child: const Text('No'),
                                  ),
                                  TextButton(
                                      child: const Text('Si'),
                                      onPressed: () async {
                                        await appState.logout();
                                      }),
                                ]),
                          );
                        },
                        icon: Image.asset(
                          _userPhoto,
                          height: 40.0,
                          width: 40.0
                        ),
                        label: Center(
                            child: Text(
                                '${userInfo.firstName}\n${userInfo.lastName}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Configuration.customerSecondaryColor,
                                ),
                                textAlign: TextAlign.center
                            )
                        ),
                      ),
                    ],
                  ),
                  body: SafeArea(
                      child: Column(
                          children: <Widget>[
                            Container(
                                height: MediaQuery.of(context).size.height * 0.45,
                                width: MediaQuery.of(context).size.width,
                                child: _selectedPhoto != null ?
                                    GestureDetector(
                                        child: _selectedPhoto,
                                        onTap: () async {
                                          FocusManager.instance.primaryFocus?.unfocus();
                                          await showDialog(
                                              context: context,
                                              builder: (_) {
                                                return Dialog(
                                                  child: InteractiveViewer(
                                                      clipBehavior: Clip.none,
                                                      maxScale: 5,
                                                      child: Container(
                                                        child: _selectedPhoto,
                                                        /*decoration: BoxDecoration(
                                                          border: Border.all(color: Configuration.customerSecondaryColor),
                                                        ),*/
                                                      )
                                                  ),
                                                );
                                              }
                                          );
                                        }
                                    )
                                    : Container(),
                            ),
                            const Divider(),
                            _photos.length < 1?
                              Container()
                              : Container(
                                  height: MediaQuery.of(context).size.height * 0.38,
                                  child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 4,
                                    mainAxisSpacing: 4),
                                    itemBuilder: (_, i) {
                                      final file = _photos[i];
                                      return GestureDetector(
                                        child: file,
                                        onTap: () {
                                          setState(() {
                                            _selectedPhoto = file;
                                          });
                                        },
                                      );
                                    },
                                    itemCount: _photos.length
                                  ),
                                )
                          ]
                      )
                  ),
                  //SpUI.buildThumbnailsGridView(state: photosState, photos: _photos, context: context),
                  floatingActionButton: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                          onPressed: () async {
                            final file = await getPhotoFromGallery(); //XFile

                            try {
                              final imageSaved = await saveImage(context, file!);

                              setState((){
                                if(imageSaved){
                                  _localData = _getScreenData();
                                  UIHelper.showSuccessfulSnackBar('Imagen almacenada exitosamente', context);
                                }else{
                                  UIHelper.showErrorSnackBar('La imagen no pudo ser almacenada', context);
                                }
                              });
                            }catch(e){

                            }
                          },
                          backgroundColor: Configuration.customerPrimaryColor,
                          child: const Icon(Icons.folder, color: Configuration.customerSecondaryColor),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 10.0)),
                        FloatingActionButton(
                          onPressed: () async {
                            final file = await getPhotoFromCamera();
                            try {
                              final imageSaved = await saveImage(context, file!);

                              setState((){
                                if(imageSaved){
                                  _localData = _getScreenData();
                                  UIHelper.showSuccessfulSnackBar('Imagen almacenada exitosamente', context);
                                }else{
                                  UIHelper.showErrorSnackBar('La imagen no pudo ser almacenada', context);
                                }
                              });
                            } catch(e){
                            }
                          },
                          backgroundColor: Configuration.customerPrimaryColor,
                          child: const Icon(Icons.camera_alt, color: Configuration.customerSecondaryColor),
                        )
                      ]
                  )
              );
            }
            else if (snapshot.hasError) {
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
              widget = Scaffold(
                  backgroundColor: Configuration.customerPrimaryColor,
                  body: Stack(
                      fit: StackFit.expand,
                      children: [
                        Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    /// Loader Animation Widget
                                    const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Configuration.customerSecondaryColor),
                                    ),
                                    const Text('Cargando...',
                                        style: TextStyle(
                                            color: Configuration.customerSecondaryColor,
                                            height: 8,
                                            fontSize: 14
                                        )
                                    )
                                  ],
                                ),
                              ),
                            ]
                        )
                      ]
                  )
              );
            }
            return widget;
          }
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Configuration.customerPrimaryColor,
          title: const Text(
              'Iniciar Sesión con Google',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Configuration.customerSecondaryColor
              )
          ),
        ),
        body: Center(
          child: ElevatedButton.icon(
            label: const Text('Iniciar Sesión con Google'),
            icon: Image.asset('assets/images/google_logo.png', height: 24),
            onPressed: () async {

              try {
                await signIn();
              }catch(_){ }

              setState(() {
                if(getLoginStatus()) {
                  _localData = _getScreenData();
                  UIHelper.showSuccessfulSnackBar('Inicio de sesión exitoso.', context);
                }else{
                  UIHelper.showErrorSnackBar('Falló el inicio de sesión.', context);
                }
              });
            }
          ),
        ),
      );
    }
  }

  Future<bool> _getPhotos(void something) async {

    _userPhoto = 'assets/images/'+ (await Cache.getUserName())! + '_user.jpg';

    //Retrieve photos only if user is logged in
    if(getLoginStatus()) {
      final filesList = await allFileList(context);
      //a este punto solo tengo los ids de las fotos en google

      if (filesList == null) {
        throw Exception();
      }

      final photos = filesList.files!.map((f){
        final photoURL = Configuration.photosURL.replaceAll('<<photoId>>', f.id!);
        return Image.network(photoURL);
      }).toList();

      //TODO: ESTARIA BUENO DEVOLVER UN OBJETO CON NOMBRE DE LA FOTO Y BYTES PARA MOSTRAR
      _photos = photos;
    }

    return true;
  }

  Future<void> _refresh() async{
    setState(() {
      _localData =  _getScreenData();
    });
  }
}