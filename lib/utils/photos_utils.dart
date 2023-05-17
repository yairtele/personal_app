import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../services/drive_api.dart';

Future<bool> saveImage(BuildContext context, XFile xfile) {
  return uploadTo(context, xfile);
}

Future<XFile?> getPhotoFromCamera() async {
  return _getPhoto(ImageSource.camera);
}

Future<XFile?> getPhotoFromGallery() async {
  return _getPhoto(ImageSource.gallery);
}

Future<XFile?> _getPhoto(ImageSource source) async {
  final pickedFile = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1800,
    maxHeight: 1800,
  );

  return pickedFile;
}

Future<File> castXFile2File(XFile xfile) async {
  final bytes = await xfile.readAsBytes();
  final fileName = xfile.path.split('/').last;
  final file = File(fileName).writeAsBytes(bytes);

  return file;
}

String getTimestamp(){
  return DateTime.now().millisecondsSinceEpoch.toString();
}