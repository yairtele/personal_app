import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navigation_app/services/athento/binary_file_info.dart';

class SpUI{
  static Widget buildThumbnailsGridView<T extends StatefulWidget>({ required State<T> state, required Map<String, XFile?> photos}) {

    return GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        shrinkWrap: true,
        children: <Widget>[
          for(final photoName in  photos.keys)
            _buildPhotoThumbnail(photoName, photos, state)
        ]
    );
  }

  static Widget _buildPhotoThumbnail<T extends StatefulWidget>(String photoName, Map<String, XFile?> photos, State<T> state) {
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
                      state.setState(() {
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
                      //if(cameraOn) {
                        final pickedPhoto = await _getPhotoFromCamera();
                        state.setState(() {
                          photos[photoName] = pickedPhoto;
                        });
                      //}
                    },
                  )
              ],
            )
          ],
        )
    );
  }

  static Widget buildProductThumbnailsGridView<T extends StatefulWidget>({ required State<T> state, required Map<String, BinaryFileInfo?> photos}) {

    return GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        shrinkWrap: true,
        children: <Widget>[
          for(final photoName in  photos.keys)
            _buildProductPhotoThumbnail(photoName, photos, state)
        ]
    );
  }

  static Widget _buildProductPhotoThumbnail<T extends StatefulWidget>(String photoName, Map<String, BinaryFileInfo?> photos, State<T> state) {
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
                    return  Image.file(File.fromRawPath(photo.bytes));
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
                      state.setState(() {
                        photos[photoName] = null;
                      });
                    },
                  )
                /*else
                  ElevatedButton( // Take photo
                    child: const Icon(FontAwesomeIcons.camera),
                    minimumSize: Size.zero,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(4),
                    ),
                    onPressed: () {
                      //if(cameraOn) {
                      /*final pickedPhoto = await _getPhotoFromCamera();
                      state.setState(() {
                        photos[photoName] = pickedPhoto;
                      });*/
                      //}
                    },
                  )*/
              ],
            )
          ],
        )
    );
  }

  static Future<XFile?> _getPhotoFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    return pickedFile;
  }
}

