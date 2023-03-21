import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class SpFileUtils{

  static Future<void> createDirectory(String directoryName) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/${directoryName}';

    if (await Directory(imagePath).exists()) {
      // La carpeta ya existe, no es necesario crearla de nuevo.
      return;
    }

    await Directory(imagePath).create(recursive: true);
    print('Carpeta creada en: $imagePath');
  }

  static String getFileExtension(String filePath) {
    var lastSlashIndex = filePath.lastIndexOf(RegExp(r'[/\\]'));

    lastSlashIndex = lastSlashIndex < 0 ? 0 : lastSlashIndex;

    final lastDotIndex = filePath.indexOf('.', lastSlashIndex);

    if(lastDotIndex < 0){
      throw Exception('The filePath "$filePath" contains no extension.');
    }

    final fileExtension = filePath.substring(lastDotIndex);

    return fileExtension;
  }

  static Future<dynamic> readJson(jsonPath) async {
    final response = await rootBundle.loadString(jsonPath);
    final data = await json.decode(response);
    return data;
  }
}