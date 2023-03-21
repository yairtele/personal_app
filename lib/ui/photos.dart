/*
 * Copyright (c) 2021 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/ui/screen_data.dart';
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

  late List<String> _photos;
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

    if(loginStatus){
      return FutureBuilder<ScreenData<void, bool>>(

          future: _localData,
          builder: (BuildContext context, AsyncSnapshot<ScreenData<dynamic, bool>> snapshot) {

            Widget widget;
            if (snapshot.connectionState == ConnectionState.done &&  snapshot.hasData) {
              final data = snapshot.data!;
              final userInfo = data.userInfo;
              //final batches = data.data!;
              //final draftBatches = batches.where((batch) => batch.state == BatchStates.Draft).toList();
              //final auditedBatches = batches.where((batch) => batch.state != BatchStates.Draft).toList();
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
                  body: SpUI.buildThumbnailsGridView(state: photosState, photos: _photos, context: context),
                  floatingActionButton: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                          onPressed: () async {
                            final file = await getPhotoFromGallery();
                            try {
                              await saveImage(file!);

                              _showSuccessfulSnackBar('Imagen almacenada exitosamente', context);
                            } catch(e){
                              _showErrorSnackBar('La imagen no pudo ser almacenada', context);
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
                              await saveImage(file!);

                              setState((){
                                _showSuccessfulSnackBar('Imagen almacenada exitosamente', context);
                              });
                            } catch(e){
                              setState((){
                                _showErrorSnackBar('La imagen no pudo ser almacenada', context);
                              });
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

              var loginOK = false;

              /*try {
                loginOK = await signIn();
              }catch(_){ }*/

              setState(() {
                if(!loginOK){
                  _showErrorSnackBar('Falló el inicio de sesión.', context);
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
/*
    //Create directory if not exists
    await SpFileUtils.createDirectory('loadedPhotos');

    //Get all photos in photos directory
    final directory = await getApplicationDocumentsDirectory();
    final photosDirectory = '$directory/loadedPhotos';

    final photosObjectDirectory = Directory(photosDirectory);
    final listOfFiles = photosObjectDirectory.listSync(recursive: false);
    final filesList = listOfFiles.toList();
    final photos = <String>[];
    for (final file in filesList) {
      if (file is File && file.path.endsWith('.png')) {
        photos.add(file.path);
      }
    }*/
    //return imagePaths;
    final manifestJson = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final photos = json.decode(manifestJson).keys.where((String key) => key.startsWith('assets/images/photos')).toList();

    _photos = photos;

    return true;
  }

  Future<void> _refresh() async{
    setState(() {
      _localData =  _getScreenData();
    });
  }
}

void _showErrorSnackBar(String message, context) {
  _showSnackBar(message, Colors.red, context);
}
void _showSuccessfulSnackBar(String message, context) {
  _showSnackBar(message, Colors.green, context);
}
void _showSnackBar(String message, MaterialColor bgColor, context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: bgColor),
  );
}