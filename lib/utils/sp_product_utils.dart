import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:navigation_app/services/athento/binary_file_info.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/services/business/product_info.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class SpProductUtils{

  static Future<ProductInfo> getProductInfoByEAN(String eanCode) {
    return BusinessServices.getProductInfoByEAN(eanCode);
  }

  static Future<XFile> binaryFileInfo2XFile(BinaryFileInfo content, String label, String parentUUID, String photoUUID) async {

    final dir = await getApplicationDocumentsDirectory();
    //final dir = await getTemporaryDirectory(); //TODO: es probable que sea mejor usar esta carpeta

    //final tempPath = dir.path + '/' + parentUUID + '/' + label + '-' + photoUUID;
    //TODO: no se debería necestar el RANDOM, ya que todos los temporales fueron borrados, pero algo no está funcionando.
    final tempPath = dir.path + '/' + parentUUID + '/' + label + '.' + Random().nextInt(1000000).toString()  + '.' +  content.fileExtension;

    final tempDirPath = dir.path + '/' + parentUUID;
    final tempDirExists = Directory(tempDirPath).existsSync();

    final fil = File(tempPath);

    if(fil.existsSync()){
      fil.deleteSync();
    }
    fil.createSync(recursive: true);
    fil.writeAsBytesSync(content.bytes, mode: FileMode.write, flush: true);

    final xFile = XFile(fil.path);//XFile.fromData(content.bytes, mimeType: content.contentType, path: tempPath);

    return xFile;
  }
}

class ProductPhotos{

  List<String> modifiedPhotos;

  ProductPhotos(this.modifiedPhotos);
}