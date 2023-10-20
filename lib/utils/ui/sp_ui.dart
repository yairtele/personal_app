import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marieyayo/services/athento/binary_file_info.dart';
import 'package:marieyayo/services/business/batch_states.dart';
import 'package:marieyayo/utils/ui/thumb_photo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
//import 'package:file_picker_cross/file_picker_cross.dart';

import '../../config/configuration.dart';
import '../sp_file_utils.dart';

class SpUI{
  static Widget buildThumbnailsGridView<T extends StatefulWidget>({ required State<T> state, /*required List<PhotoObject> photos**/required List<Image> photos, required BuildContext context}) {

    final _mediaQuery = MediaQuery.of(context).size;
    final  desktopCrossAxisElements = _mediaQuery.width < 300? 1 : (_mediaQuery.width / 300).floor();
    final children = <Widget>[];
    for(var photoIndex = 0; photoIndex < photos.length; photoIndex++){
      //var photoName = photos[photoIndex].name;
      //var photoId = photos[photoIndex].id;
      var photo = photos[photoIndex];
      children.add(_buildPhotoThumbnail(/*photoName, photoId*/ photo, state, context));
    }

    return GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: Platform.isAndroid? 2 : desktopCrossAxisElements,
        shrinkWrap: true,
        children: children
    );
  }

  static Widget _buildPhotoThumbnail<T extends StatefulWidget>(/*String photoName,*/ Image photo, State<T> state, BuildContext context) {

    //final photoURL = Configuration.photosURL.replaceAll('<<photoId>>', photoId);

    return Container(
        padding: const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 4),
        decoration: const BoxDecoration(
            color: Configuration.customerPrimaryColor
        ),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                  child: photo,
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
                                  child: photo,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Configuration.customerSecondaryColor),
                                  ),
                                )
                            ),
                          );
                        }
                    );
                  }
              ),
            ),
          ],
        )
    );
  }
  static Future<XFile?> _getPhotoFromCamera() async {
    return _getPhoto(ImageSource.camera);
  }

  static Future<XFile?> _getPhotoFromGallery() async {
    if(Platform.isAndroid)
      return _getPhoto(ImageSource.gallery);
    else
      return _getPhotoFromDesktopLocalStorage();
  }

  static Future<XFile?> _getPhotoFromDesktopLocalStorage() async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowedExtensions: ['jpg', 'pdf', 'doc']
    ); //FilePickerResult?

    var file_picked;
    if (result != null) {
      file_picked = File(result.files.single.path!); //File
    } else {
      throw Error();
    }
    /*final file_picked = await FilePickerCross.importFromStorage(
        type: FileTypeCross.image,
        fileExtension: 'png, jpg, jpeg'
    ).onError((error, _) {
      throw Error();
    });*/

    return _file2XFile(file_picked);
  }

  static XFile? _file2XFile(File filePicked) {
    final fileBytes = filePicked.readAsBytesSync();
    final filePath = filePicked.path;

    return XFile.fromData(fileBytes, path: filePath, mimeType: extension(filePath));
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
        (photoParentState == BatchStates.InfoPendiente && photoState == BatchStates.InfoPendiente)); //TODO: para que preguntar por estado del batch en el término derecho del ||?
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