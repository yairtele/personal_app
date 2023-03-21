import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveImage(XFile xfile) async {

  //final image = await castXFile2File(xfile);

  final directory = await getApplicationDocumentsDirectory(); //Directory
  final filePath = directory.path + '/loadedPhotos/' + getTimestamp() + '.png';
  final file = File(filePath); //File

  await file.writeAsBytes(await xfile.readAsBytes());
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