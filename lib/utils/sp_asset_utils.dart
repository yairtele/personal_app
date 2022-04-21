
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class SpAssetUtils {

  static Future<XFile> getImageXFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');

    await file.create(recursive: true);

    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    //final bytes = byteData.buffer.asUint8List( byteData.offsetInBytes, byteData.lengthInBytes);
    //return XFile.fromData(bytes);

    final xFile = XFile(file.path);

    return xFile;
  }
}