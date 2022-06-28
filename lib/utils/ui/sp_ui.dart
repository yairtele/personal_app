import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navigation_app/services/athento/binary_file_info.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/batch_states.dart';
import 'package:navigation_app/services/business/photo_detail.dart';
import 'package:navigation_app/utils/sp_product_utils.dart';
import 'package:navigation_app/utils/ui/thumb_photo.dart';

import '../sp_file_utils.dart';

class SpUI{
  static Widget buildThumbnailsGridView<T extends StatefulWidget>({ required State<T> state, required Map<String, ThumbPhoto> photos, required XFile dummyPhoto, required String photoParentState, required BuildContext context}) {

    return GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        shrinkWrap: true,
        children: <Widget>[
          for(final photoName in  photos.keys)
            _buildPhotoThumbnail(photoName, photos, state, dummyPhoto, photoParentState, context)
        ]
    );
  }

  static Widget _buildPhotoThumbnail<T extends StatefulWidget>(String photoName, Map<String, ThumbPhoto> photos, State<T> state, XFile dummyPhoto, photoParentState, BuildContext context) {
    final photo = photos[photoName]!;

    return Container(
        padding: const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 0),
        decoration: BoxDecoration(
          border: Border.all(
              color: photo.state == BatchStates.InfoPendiente ?  Colors.yellow : Colors.blueGrey,
              width: photo.state == BatchStates.InfoPendiente ? 3 : 1,
              style: BorderStyle.solid
          )
        ),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
              child: Image.file(File(photo.photo.path), fit: BoxFit.fitWidth),
              onTap: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                if (photo.isDummy){
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                          title: const Text('Cargar foto'),
                          content: const Text('Seleccionar tipo de carga'),
                          actions: [
                            TextButton(
                                child: const Text('Cámara'),
                                onPressed: () {
                                  _getPhotoFromSource(state, photoParentState, photo, dummyPhoto, _getPhotoFromCamera);
                                  Navigator.pop(context);
                                }
                            ),
                            TextButton(
                                child: const Text('Galería'),
                                onPressed: () {
                                  _getPhotoFromSource(state, photoParentState, photo, dummyPhoto, _getPhotoFromGallery);
                                  Navigator.pop(context);
                                }),
                          ]));
                } else {
                  await showDialog(
                      context: context,
                      builder: (_) {
                      return Dialog(
                        child: InteractiveViewer(
                            maxScale: 5,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.file(File(photo.photo.path))
                            )
                        ),
                      );
                    }
                );
    }
              }
            ),
            ),
            Row(
              children: [
                Expanded(child: Text(_getThumbTitle(photoName), textAlign: TextAlign.center)), // Photo name
                if(photo.isDummy == false)
                  ElevatedButton( // Delete photo
                    child: const Icon(FontAwesomeIcons.trash),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.all(4),
                    ),
                    onPressed: _shouldDisablePhotoButton(photoParentState, photo.state) ? null : () async {
                      //TODO: ver si se debe borrar el archivo donde estaba la foto
                      state.setState(() {
                        //photos[photoName] = ThumbPhoto(dummyPhoto,  true);
                        photo.isDummy = true;
                        photo.photo = dummyPhoto;
                        photo.hasChanged = true;
                      });
                    },
                  )
                else
                  Row(
                    children: [
                      if(Platform.isAndroid)
                        ElevatedButton( // Take photo
                          child: const Icon(FontAwesomeIcons.camera),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.all(4),
                          ),
                          onPressed: _shouldDisablePhotoButton(photoParentState, photo.state) ? null :() async {
                            //if(cameraOn) {
                            final pickedPhoto = await _getPhotoFromCamera();
                            state.setState(() {
                              photo.photo = pickedPhoto ?? dummyPhoto;
                              photo.isDummy = pickedPhoto == null;
                              photo.hasChanged = true;
                            });
                          },
                        ),
                      ElevatedButton( // Take photo
                        child: const Icon(FontAwesomeIcons.folder),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.all(4),
                        ),
                        onPressed: _shouldDisablePhotoButton(photoParentState, photo.state) ? null :() async {
                          //if(cameraOn) {
                          final pickedPhoto = await _getPhotoFromGallery();
                          state.setState(() {
                            photo.photo = pickedPhoto ?? dummyPhoto;
                            photo.isDummy = pickedPhoto == null;
                            photo.hasChanged = true;
                          });
                        },
                      )
                    ],
                  )
              ],
            )
          ],
        )
    );
  }

  /*
  static Widget buildProductThumbnailsGridView<T extends StatefulWidget>({ required State<T> state, required Map<String, PhotoDetail> photos, required BuildContext context, required ProductPhotos modifiedPhotos,required Batch batch}) {

    return GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        shrinkWrap: true,
        children: <Widget>[
          for(final photoName in  photos.keys)
            _buildProductPhotoThumbnail(photoName, photos, state, context, modifiedPhotos,batch)
        ]
    );
  }

  static Widget _buildProductPhotoThumbnail<T extends StatefulWidget>(String photoName, Map<String, PhotoDetail> photos, State<T> state, BuildContext context, ProductPhotos modifiedPhotos,Batch batch) {
    final photo = photos[photoName]!.content;
    final photoUUID = photos[photoName]!.uuid;

    return Container(
        padding: const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 0),
        decoration: BoxDecoration(
          color: (photos[photoName]. ?? 'sasas') == 'img_not_found.jpg' ?  Colors.yellow.shade300: Theme.of(context).backgroundColor,
          border: Border.all(
                color: Colors.blueGrey, width: 1, style: BorderStyle.solid)
        ),
        child: Column(
          children: [
            Expanded( // Show photo or icon
                child: ((){
                  if (photo != null)
                    return Image.file(File(photos[photoName]!.content!.path)); //para obtener bytes de un BinaryFileInfo es Image.memory(photo.bytes);
                  else
                    return const Icon(FontAwesomeIcons.camera);
                })()
            ),
            Row(
              children: [
                Expanded(child: Text(_getThumbTitle(photoName), textAlign: TextAlign.center)), // Photo name
                if(photo != null) ...[
                  if (batch.state==BatchStates.Draft || batch.state==BatchStates.InfoPendiente) //TODO: revisar si hay que preguntar por el estado del batch o de qué cosa
                  ElevatedButton( //Edit photo
                    child: const Icon(FontAwesomeIcons.edit),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.all(4),
                    ),
                    onPressed: () async {

                      final pickedPhoto = await _getPhotoFromCamera();

                      state.setState(() {
                        modifiedPhotos.modifiedPhotos.add(photoName);
                        photos[photoName] = PhotoDetail(uuid: photoUUID, content: pickedPhoto);
                      });
                    },
                  ),
                  if (batch.state==BatchStates.Draft || batch.state==BatchStates.InfoPendiente)
                  ElevatedButton( // Delete photo
                    child: const Icon(FontAwesomeIcons.trash),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.all(4),
                    ),
                    onPressed: () async {
                      //showDeleteAlertDialog(context, state, photos, photoName);
                      state.setState(() {
                        modifiedPhotos.modifiedPhotos.add(photoName);
                        photos[photoName] = PhotoDetail(uuid: photoUUID, content: null);
                      });
                    },
                  )]
                else
                  if (batch.state==BatchStates.Draft || batch.state==BatchStates.InfoPendiente)
                  ElevatedButton( // Take photo
                    child: const Icon(FontAwesomeIcons.camera),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.all(4),
                    ),
                    onPressed: () async {

                      final pickedPhoto = await _getPhotoFromCamera();

                      state.setState(() {
                        modifiedPhotos.modifiedPhotos.add(photoName);
                        photos[photoName] = PhotoDetail(uuid: photoUUID, content: pickedPhoto);
                      });
                    },
                  )
              ],
            )
          ],
        )
    );
  }
*/
/*
  static Widget buildReturnRequestThumbnailsGridView<T extends StatefulWidget>({ required State<T> state, required Map<String, PhotoDetail> photos, required BuildContext context, required ProductPhotos modifiedPhotos,required Batch batch}) {

    return GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        shrinkWrap: true,
        children: <Widget>[
          for(final photoName in  photos.keys)
            _buildReturnRequestPhotoThumbnail(photoName, photos, state, context, modifiedPhotos,batch)
        ]
    );
  }

  static Widget _buildReturnRequestPhotoThumbnail<T extends StatefulWidget>(String photoName, Map<String, PhotoDetail> photos, State<T> state, BuildContext context, ProductPhotos modifiedPhotos,Batch batch) {
    final photo = photos[photoName]!.content;
    final photoUUID = photos[photoName]!.uuid;

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
                    return Image.file(File(photos[photoName]!.content!.path)); //para obtener bytes de un BinaryFileInfo es Image.memory(photo.bytes);
                  else
                    return const Icon(FontAwesomeIcons.camera);
                })()
            ),
            Row(
              children: [
                Expanded(child: Text(_getThumbTitle(photoName), textAlign: TextAlign.center)), // Photo name
                  if(photo != null) ...[
                    if (batch.state==BatchStates.Draft || batch.state==BatchStates.InfoPendiente)
                    ElevatedButton( //Edit photo
                      child: const Icon(FontAwesomeIcons.edit),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.all(4),
                      ),
                      onPressed: () async {

                        final pickedPhoto = await _getPhotoFromCamera();

                        state.setState(() {
                          modifiedPhotos.modifiedPhotos.add(photoName);
                          photos[photoName] = PhotoDetail(uuid: photoUUID, content: pickedPhoto);
                        });
                      },
                    ),
                    if (batch.state==BatchStates.Draft || batch.state==BatchStates.InfoPendiente)
                    ElevatedButton( // Delete photo
                      child: const Icon(FontAwesomeIcons.trash),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.all(4),
                      ),
                      onPressed: () async {
                        //showDeleteAlertDialog(context, state, photos, photoName);
                        state.setState(() {
                          modifiedPhotos.modifiedPhotos.add(photoName);
                          photos[photoName] = PhotoDetail(uuid: photoUUID, content: null);
                        });
                      },
                    )]
                  else
                    if (batch.state==BatchStates.Draft || batch.state==BatchStates.InfoPendiente)
                    ElevatedButton(// Take photo
                      child: const Icon(FontAwesomeIcons.camera),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.all(4),
                      ),
                      onPressed: () async {

                        final pickedPhoto = await _getPhotoFromCamera();

                        state.setState(() {
                          modifiedPhotos.modifiedPhotos.add(photoName);
                          photos[photoName] = PhotoDetail(uuid: photoUUID, content: pickedPhoto);
                        });
                      },
                   )
                  ],
            )
          ],
        )
    );
  }
*/

  static Future<XFile?> _getPhotoFromCamera() async {
    return _getPhoto(ImageSource.camera);
  }

  static Future<XFile?> _getPhotoFromGallery() async {
    return _getPhoto(ImageSource.gallery);
  }

  static Future<XFile?> _getPhoto(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    return pickedFile;
  }

  static Future<BinaryFileInfo> _xFile2BinaryInfo(XFile? xFile) async {
    final _mimeType = xFile!.mimeType!;
    final _fileExtension = SpFileUtils.getFileExtension(xFile.path);
    final _bytes = await xFile.readAsBytes();

    return BinaryFileInfo(contentType: _mimeType, fileExtension: _fileExtension, bytes: _bytes);
  }

  static String _getThumbTitle(String photoName) {
    final thumbTitle = photoName.substring(0,1 ).toUpperCase() + photoName.substring(1).replaceAll('_', ' ');
    return thumbTitle;
  }

  static void showDeleteAlertDialog<T extends StatefulWidget>(BuildContext context, State<T> state, Map<String, BinaryFileInfo?> photos, String photoName) {
    // set up the buttons
    final cancelButton = TextButton(
      child: const Text('No'),
      onPressed:  () {},
    );
    final continueButton = TextButton(
      child: const Text('Si, continuar'),
      onPressed:  () {
        //TODO: borrar el archivo donde estaba la foto
        state.setState(() {
          photos[photoName] = null;
        });
      },
    );
    // set up the AlertDialog
    final alert = AlertDialog(
      title: const Text('Eliminar imagen'),
      content: const Text('Está seguro que desea eliminar la imagen seleccionada?'),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static bool _shouldDisablePhotoButton(String photoParentState, String photoState) {
    return !(photoParentState == BatchStates.Draft ||
        (photoParentState == BatchStates.InfoPendiente && photoState == BatchStates.InfoPendiente));
  }

  static void _getPhotoFromSource (State state, String photoParentState, ThumbPhoto photo, XFile dummyPhoto, Future<XFile?> getPhotoFunction ()){
    if(! _shouldDisablePhotoButton(photoParentState, photo.state)) {
      () async {
        final pickedPhoto = await getPhotoFunction();
        state.setState(() {
          photo.photo = pickedPhoto ?? dummyPhoto;
          photo.isDummy = pickedPhoto == null;
          photo.hasChanged = true;
        });
      }();
    }
  }
}