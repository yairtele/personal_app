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

  static Future<XFile> binaryFileInfo2XFile(BinaryFileInfo content, String label, String photoUUID) async {
    //final dir = await getApplicationDocumentsDirectory();
    final dir = await getTemporaryDirectory();
    final tempPath = dir.path + '/' + label + '-' + photoUUID;
    final fil = File(tempPath);
    fil.writeAsBytes(content.bytes);

    final xFile = XFile(tempPath);//XFile.fromData(content.bytes, mimeType: content.contentType, path: tempPath);

    return xFile;
  }
}

class ProductPhotos{

  List<String> modifiedPhotos;

  ProductPhotos(this.modifiedPhotos);
}