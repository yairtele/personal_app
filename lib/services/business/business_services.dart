import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:marieyayo/config/cache.dart';
import 'package:marieyayo/config/configuration.dart';
import 'package:marieyayo/services/athento/athento_field_name.dart';
import 'package:marieyayo/services/athento/basic_auth_config_provider.dart';
import 'package:marieyayo/services/athento/bearer_auth_config_provider.dart';
//import 'package:marieyayo/services/athento/binary_file_info.dart';
import 'package:marieyayo/services/athento/config_provider.dart';
import 'package:marieyayo/services/athento/sp_athento_services.dart';
import 'package:marieyayo/services/business/batch.dart';
import 'package:marieyayo/services/business/batch_states.dart';
import 'package:marieyayo/services/business/product.dart';
import 'package:marieyayo/services/business/product_photo.dart';
import 'package:marieyayo/services/business/return_photo.dart';
import 'package:marieyayo/services/business/return_request.dart';
import 'package:marieyayo/services/business/business_exception.dart';
import 'package:marieyayo/utils/sp_file_utils.dart';
import 'package:marieyayo/utils/sp_functions_utils.dart';
import 'package:marieyayo/utils/sp_product_utils.dart';
import 'new_return.dart';
import 'package:path_provider/path_provider.dart';

class BusinessServices {
  static const String _batchDocType = 'lote_lif';
  static const String _returnRequestDocType = 'solicitud_auditoria_kvg';
  static const String _productDocType = 'producto_wli';
  static const String _photoDocType = 'foto_oxc';


  static Future<UserInfo?> getUserInfo(String userNameOrUUID) async {
    const json = Configuration.usersJson;
    final userJson = json[userNameOrUUID];
    const userIndex = 1; //TODO: PAPP - Calcular pos dentro del json

    final result = UserInfo(
        idNumber: userIndex.toString(),
        userName: userNameOrUUID,
        firstName: userJson!['firstName']!,
        lastName: userJson['lastName']!,
        email: userJson['email']!
    );

    return result;
  }

  static Future<TRowObject?> _getRowAsObjectFromFile<TRowObject>({required String fileName, required int chunkSize,
        required String lineSeparator, required String columnSeparator, required bool Function(List<String> row)  equals,
        required TRowObject objectBuilder(List<String> row)}) async {

    final localFolderPath = (await getApplicationDocumentsDirectory()).path;
    final productsFolderPath = Directory('$localFolderPath/products');

    final productsFile = File('${productsFolderPath.path}/$fileName');

    final productsRndFile = productsFile.openSync(mode: FileMode.read);

    var accumulatedReads = '';
    const start = 0;

    int bytesRead;
    const utf8Decoder = Utf8Decoder(allowMalformed: true);

    do {
      final readBuffer = List<int>.filled(chunkSize, 0);

      bytesRead = productsRndFile.readIntoSync(readBuffer, start);
      //accumulatedReads += utf8.decoder.convert(readBuffer, 0, bytesRead);
      accumulatedReads += utf8Decoder.convert(readBuffer, 0, bytesRead);
      //TODO: unir fragmento de línea final con línea siguiente
      final newLines = accumulatedReads.split(lineSeparator);

      if(newLines.length > 1 || bytesRead < chunkSize){
        final linesToProcess = (bytesRead < chunkSize ? newLines.length : newLines.length - 1);
        // Buscar producto por EAN en cada línea
        for(var i=0; i< linesToProcess; i++){
          final row = newLines[i].split(columnSeparator);
          if(equals(row)){
            return objectBuilder(row);
          }
        }
        accumulatedReads = newLines.last;
      }

      //start += chunkSize;
    } while (bytesRead == chunkSize);

    return null;
  }

  static Map<String, String> _getFieldNameInferenceConfig({required String defaultPrefix}) {
    return  {
      'defaultPrefix': defaultPrefix,
    };
  }

  static List<int> _getImageByteArray({required String path}) {
    final file = File(path);
    return file.readAsBytesSync();
  }

  static Future<void> _deletePhotoCacheDirectory(String directoryName) async {
    //TODO: IMPORTANTE: Sólo se están borrando fotos si se grabaron las fotos. Habría que borrar cache de fotos desde las pantallas, apenas se sale de la pantalla.

    final dir = await getApplicationDocumentsDirectory();
    //final dir = await getTemporaryDirectory();
    final tempPath = dir.path + '/' + directoryName;
    final tempDir = Directory(tempPath);
    final tempDirExists = tempDir.existsSync(); // Para debug
    if(tempDirExists){
      tempDir.deleteSync(recursive: true);
    }
  }

  static void _silentlyDeleteFile(String path){
    try{
      if (!path.contains('img_not_found.jpg')){
        File(path).delete();
      }
    }
    on Exception catch (e){
      print('Error borrando archivo: ' + path);
      final foo = e;
    }
  }
}