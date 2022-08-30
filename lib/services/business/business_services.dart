import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:navigation_app/config/cache.dart';
import 'package:navigation_app/config/configuration.dart';
import 'package:navigation_app/services/athento/athento_field_name.dart';
import 'package:navigation_app/services/athento/basic_auth_config_provider.dart';
import 'package:navigation_app/services/athento/bearer_auth_config_provider.dart';
//import 'package:navigation_app/services/athento/binary_file_info.dart';
import 'package:navigation_app/services/athento/config_provider.dart';
import 'package:navigation_app/services/athento/sp_athento_services.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/batch_states.dart';
import 'package:navigation_app/services/business/product.dart';
import 'package:navigation_app/services/business/product_photo.dart';
import 'package:navigation_app/services/business/return_photo.dart';
import 'package:navigation_app/services/business/return_request.dart';
import 'package:navigation_app/services/business/business_exception.dart';
import 'package:navigation_app/services/business/product_info.dart';
import 'package:navigation_app/utils/sp_file_utils.dart';
import 'package:navigation_app/utils/sp_functions_utils.dart';
import 'package:navigation_app/utils/sp_product_utils.dart';
import '../newsan_services.dart';
import 'new_return.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:collection/collection.dart';

import 'photo_detail.dart';

//TODO: PAPP - Pasar a archivo o db
const usersInfo = '''{
  "marystique": {
    "firstName": "Marie",
    "lastName": "Fages",
    "email": "marie.brugiroux@outlook.fr"
  },
  "yairtele": {
    "firstName": "Yair",
    "lastName": "Telezon",
    "email": "yairtele@yahoo.com.ar"
  }
}''';

class BusinessServices {
  static const String _batchDocType = 'lote_lif';
  static const String _returnRequestDocType = 'solicitud_auditoria_kvg';
  static const String _productDocType = 'producto_wli';
  static const String _photoDocType = 'foto_oxc';


  static Future<UserInfo?> getUserInfo(String userNameOrUUID) async {
    final json = jsonDecode(usersInfo);
    final userJson = json[userNameOrUUID];
    const userIndex = 1; //TODO: PAPP - Calcular pos dentro del json
    final result = json != null? UserInfo(idNumber: userIndex.toString(),
        userName: userNameOrUUID, firstName: userJson['firstName'],
        lastName: userJson['lastName'], email: userJson['email']): null;
    return result;
    /*final configProvider = await  _createConfigProvider();
    return SpAthentoServices.getUserInfo(configProvider, userNameOrUUID);*/
  }

  static Future<ProductInfo> getProductInfoByEAN(String eanCode) async {
    return getProductInfoByEANfromFile(eanCode);
  }

  static Future<ProductInfo> getProductInfoByEANfromFile(String eanCode) async {
    const productFileSearchKey = 'codigoEan';
    return _getProductInfoByEANorCodefromFile(productFileSearchKey, eanCode);

  }

  static Future<ProductInfo> getProductInfoByCommercialCode(String commercialCode) async {
    //return getProductInfoByCommercialCodeFromArray(commercialCode);
    return _getProductInfoByCommercialCodefromFile(commercialCode);
  }

  static Future<ProductInfo> _getProductInfoByCommercialCodefromFile(String commercialCode) async {
    const productFileSearchKey = 'codigoComercial';
    return _getProductInfoByEANorCodefromFile(productFileSearchKey, commercialCode);

  }

  static Future<ProductInfo> _getProductInfoByEANorCodefromFile(String productFileSearchKey, String productFileSearchValue) async {
    const chunkSize = 32 * 1024;
    final searchPattern = RegExp(r'[^A-Z0-9-]', caseSensitive: false);
    const replaceString = '-';

    productFileSearchValue = productFileSearchValue.replaceAll(searchPattern, replaceString);

    final productFullInfo = await NewsanServices.getProductFullInfo(productFileSearchKey, productFileSearchValue);
    final productMasterInfo = productFullInfo['productMasterInfo'];

    if(productMasterInfo == null){
      throw BusinessException('No se ha podido encontrar un producto con el código "$productFileSearchValue" en el maestro de productos.');
    }

    final productSalesInfo = productFullInfo['productSalesInfo'];

    const BUSINESS_UNIT_INDEX = 0;
    final productAuditRules = await _getRowAsObjectFromFile(
        fileName: Configuration.rulesFileName,//'rules_db.csv' ,
        chunkSize: chunkSize,
        lineSeparator: '\r\n',
        columnSeparator: '\t',
        equals: (List<String> row) => row[BUSINESS_UNIT_INDEX] == productMasterInfo.businessUnit,
        objectBuilder: _createProductAuditRules);

    return ProductInfo.create(
        EAN: productMasterInfo.ean,
        commercialCode: productMasterInfo.commercialCode,
        sku: productMasterInfo.sku,
        description: productMasterInfo.description,
        brand: productMasterInfo.brand,
        legalEntity: productMasterInfo.legalEntity,
        businessUnit: productMasterInfo.businessUnit,
        salesInfo: productSalesInfo,
        auditRules: productAuditRules,
    );
  }

  static Future<ProductAuditRules?> productAuditRules(String businessUnit) async {
    const chunkSize = 32 * 1024;

    const BUSINESS_UNIT_INDEX = 0;
    return _getRowAsObjectFromFile(
      fileName: 'rules_db.csv' ,
      chunkSize: chunkSize,
      lineSeparator: '\r\n',
      columnSeparator: '\t',
      equals: (List<String> row) => row[BUSINESS_UNIT_INDEX] == businessUnit,
      objectBuilder: _createProductAuditRules
    );
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

  static ProductMasterInfo _createProductMasterInfo(List<String> row){
    return ProductMasterInfo.fromCsvRow(row);
  }

  static ProductSalesInfo _createProductSalesInfo(List<String> row){
    return ProductSalesInfo.fromCsvRow(row);
  }

  static ProductAuditRules _createProductAuditRules(List<String> row){
    return ProductAuditRules.fromCsvRow(row);
  }
  static Map<String, dynamic> _getReturnRequestFieldValues(String returnRequestTitle, Batch batch, NewReturn newReturn) {
    final lastSell = newReturn.lastSell != null ? DateFormat('yyyy-MM-dd').format(newReturn.lastSell!).toString() : null;

    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    // Obtener valores de campos para la nueva solicitud
    final returnRequest = ReturnRequest(
        title: returnRequestTitle,
        batchNumber: batch.batchNumber,
        EAN: newReturn.EAN,
        sku: newReturn.sku,
        commercialCode: newReturn.commercialCode,
        description: newReturn.description,
        retailReference: newReturn.retailReference,
        brand: newReturn.brand,
        isAuditable: newReturn.isAuditable,
        quantity: newReturn.quantity,
        lastSell: lastSell,
        price: newReturn.price,
        legalEntity: newReturn.legalEntity,
        businessUnit: newReturn.businessUnit,
        observations: newReturn.observations,
        customer_account: newReturn.customer_account
    );
    final fieldValues = returnRequest.toJSON();

    //No enviar el campo autonumérico y el uuid de la solicitud
    fieldValues.removeWhere((key, value) => key == ReturnRequestAthentoFieldName.requestNumber || key == ReturnRequestAthentoFieldName.uuid);
    return fieldValues;
  }

  static Map<String, dynamic> _getProductFieldValues(String productTitle, NewReturn newReturn) {
    // Obtener valores de campos para la nueva solicitud
    final product = Product(
        requestNumber: null,
        title: productTitle,
        EAN: newReturn.EAN.trim(),
        commercialCode: newReturn.commercialCode.trim(),
        description: newReturn.description.trim(),
        retailReference: newReturn.retailReference.trim(),
        observations: newReturn.observations
    );
    final fieldValues = product.toJSON();

    //No enviar el campo autonumérico ni el uuid de la solicitud
    fieldValues.removeWhere(
            (key, value) =>  key == ProductAthentoFieldName.uuid ||
                             key == ProductAthentoFieldName.requestNumber ||
                             key == AthentoFieldName.state
    );
    return fieldValues;
  }

  static Map<String, dynamic>  _getPhotoFieldValues(String photoName, bool isDummy) {
    return {
      ProductPhotoAthentoFieldName.photoType: photoName,
      ProductPhotoAthentoFieldName.isDummy: isDummy,
    };
  }

  static Map<String, String> _getFieldNameInferenceConfig({required String defaultPrefix}) {
    return  {
      'defaultPrefix': defaultPrefix,
    };
  }

  static Map<String, String> _getBatchFieldNameInferenceConfig() {
    return _getFieldNameInferenceConfig(defaultPrefix: 'lote_lif_');
  }

  static  Map<String, String> _getReturnRequestFieldNameInferenceConfig() {
    return _getFieldNameInferenceConfig(defaultPrefix: 'solicitud_auditoria_kvg_');
  }

  static  Map<String, String> _getProductFieldNameInferenceConfig() {
    var productInferenceConfig = _getFieldNameInferenceConfig(defaultPrefix: 'producto_wli_');
    productInferenceConfig['observaciones'] = 'solicitud_auditoria_kvg_observaciones';
    return productInferenceConfig;
  }

  static  Map<String, String> _getPhotoFieldNameInferenceConfig() {
    return _getFieldNameInferenceConfig(defaultPrefix: 'foto_oxc_');
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

class ProductMasterInfo{
  String ean;
  String commercialCode;
  String sku;
  String description;
  String brand;
  String businessUnit;
  String legalEntity; //Persona jurídica

  ProductMasterInfo.create({
    required this.ean,
    required this.commercialCode,
    required this.sku,
    required this.description,
    required this.brand,
    required this.businessUnit,
    required this.legalEntity //Persona jurídica
  }){}

  ProductMasterInfo({ required this.ean, required this.commercialCode,
    required this.sku,required this.description, required this.brand,
    required this.businessUnit, required this.legalEntity});

  ProductMasterInfo.fromCsvRow(List<String> row) : this(
    ean: row[3],
    commercialCode: row[1],
    sku: row[0],
    description: row[2],
    brand: row[5],
    businessUnit: row[6],
    legalEntity: row[4]
  );
}

class ProductSalesInfo{
  DateTime lastSellDate;
  double price;
  String retailAccount;

  ProductSalesInfo.create({
    required this.lastSellDate,
    required this.price,
    required this.retailAccount}){}

  ProductSalesInfo({ required this.lastSellDate, required this.price, required this.retailAccount});

  ProductSalesInfo.fromCsvRow(List<String> row) : this(
      lastSellDate: SpFunctionsUtils.parseLastSellDate(row[0]),
      price: SpFunctionsUtils.parseProductPrice(row[5]),
      retailAccount: row[2],
  );//TODO: YAYO: Comentar cuando se habilite ws

}

class ProductAuditRules{
  List<PhotoAuditInfo> photos;
  Duration lastSaleMaxAge;

  ProductAuditRules({ required this.photos, required this.lastSaleMaxAge});

  ProductAuditRules.fromCsvRow(List<String> row) : this(
      photos: _createAuditPhotoInfos(row[3]),
      lastSaleMaxAge: Duration(days: int.parse(row[4])),
  );
  static List<PhotoAuditInfo> _createAuditPhotoInfos(String photoLabelsCSL){
    final photoLabels = photoLabelsCSL.split(',');
    return photoLabels.map((photoLabel) => PhotoAuditInfo.fromLabel(photoLabel)).toList(growable: false);
  }
}

class PhotoAuditInfo{
  String label;
  String name;
  PhotoAuditInfo({required this.label, required this.name});

  PhotoAuditInfo.fromLabel(String label): this(label: label, name: _sanitize(label));

  static String _sanitize(String label){
    return label.toLowerCase().replaceAll(' ', '_');
  }
}