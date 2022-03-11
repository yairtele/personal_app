import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:navigation_app/config/cache.dart';
import 'package:navigation_app/config/configuration.dart';
import 'package:navigation_app/services/athento/athento_field_name.dart';
import 'package:navigation_app/services/athento/basic_auth_config_provider.dart';
import 'package:navigation_app/services/athento/bearer_auth_config_provider.dart';
import 'package:navigation_app/services/athento/config_provider.dart';
import 'package:navigation_app/services/athento/sp_athento_services.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/product.dart';
import 'package:navigation_app/services/business/return_request.dart';
import 'package:navigation_app/services/business/business_exception.dart';
import 'package:navigation_app/services/business/product_info.dart';
import 'package:navigation_app/utils/sp_file_utils.dart';
import '../newsan_services.dart';
import 'new_return.dart';
import 'package:path_provider/path_provider.dart';

class BusinessServices {
  static const String _batchDocType = 'lote_lif';
  static const String _returnRequestDocType = 'solicitud_auditoria_kvg';
  static const String _productDocType = 'producto_wli';
  static const String _photoDocType = 'foto_oxc';


  static Future<UserInfo> getUserInfo(String userNameOrUUID) async {
    final configProvider = await  _createConfigProvider();
    return SpAthentoServices.getUserInfo(configProvider, userNameOrUUID);
  }

  static Future<String> getCompanyName(String cuit) async {
    return NewsanServices.getCompanyInfo(cuit);
  }

  static Future<void> createBatch(Batch batch) async {
    final fieldNameInferenceConfig = _getBatchFieldNameInferenceConfig();

    final configProvider = await  _createConfigProvider(fieldNameInferenceConfig);

    //TODO: ver cómo obtener el id del espacio.
    //TODO: DIRECTAMENTE CONSUKLTAR SIN containerUUID (nosotros deberíamos tener un usuario retail para saber buscar nuestras pruebas).

    final title = '${batch.retailReference}-${batch.description}'; // Se supone que Athento asigna nombre automáticamente, pero por las dudas...
    final fieldValues = batch.toJSON();

    //No enviar el campo autonumérico del Lote
    fieldValues.removeWhere((key, value) => key == BatchAthentoFieldName.batchNumber);

    await SpAthentoServices.createDocument( configProvider: configProvider,
        containerUUID: null,
        docType: _batchDocType,
        title: title,
        fieldValues: fieldValues
    );
  }

  static Future<List<Batch>> getBatches() async {
    final fieldNameInferenceConfig = _getBatchFieldNameInferenceConfig();
    final configProvider =
        await  _createConfigProvider(fieldNameInferenceConfig);
    final selectFields = [
      BatchAthentoFieldName.uuid,
      BatchAthentoFieldName.title,
      BatchAthentoFieldName.batchNumber,
      BatchAthentoFieldName.retailReference,
      BatchAthentoFieldName.description,
      BatchAthentoFieldName.cuitRetail,
      BatchAthentoFieldName.retailCompanyName,
      BatchAthentoFieldName.observation,
    ];

    const whereExpression = "WHERE ecm:currentLifeCycleState = 'Draft'";

    final entries = await SpAthentoServices.findDocuments(
        configProvider, _batchDocType, selectFields, whereExpression);
    final batches = entries.map((e) => Batch.fromJSON(e));
    return batches.toList();
  }

  static Future<List<ReturnRequest>> getReturnRequestsByBatchNumber({@required String batchNumber}) async {
    //Obtener diccionario de inferencia de nombres de campo
    final fieldNameInferenceConfig = _getReturnRequestFieldNameInferenceConfig();
    final batchFieldNameInferenceConfig = _getBatchFieldNameInferenceConfig();

    // Obtener config provider para Bearer Token
    final configProvider = await  _createConfigProvider(fieldNameInferenceConfig);

    //Definir campos del SELECT
    final selectFields = [
      AthentoFieldName.uuid,
      AthentoFieldName.title,
      ReturnRequestAthentoFieldName.requestNumber,
      ReturnRequestAthentoFieldName.batchNumber,
      ReturnRequestAthentoFieldName.EAN,
      ReturnRequestAthentoFieldName.commercialCode,
      ReturnRequestAthentoFieldName.description,
      ReturnRequestAthentoFieldName.retailReference,
      ReturnRequestAthentoFieldName.quantity,
      ReturnRequestAthentoFieldName.isAuditable,
    ];

    // Construir WHERE expression
    final parentBatchNumber = ' parent:metadata.${batchFieldNameInferenceConfig['defaultPrefix']}${BatchAthentoFieldName.batchNumber}';
    final whereExpression = "WHERE ecm:currentLifeCycleState = 'Draft' AND $parentBatchNumber = '$batchNumber'";

    // Invocar a Athento
    final entries = await SpAthentoServices.findDocuments(
        configProvider, _returnRequestDocType, selectFields, whereExpression);

    //Convertir resultado a objetos ReturnRequest y retornar resultado
    final returns = entries.map((e) => ReturnRequest.fromJSON(e));
    return returns.toList();
  }

  static Future<ProductInfo> getProductInfoByEAN(String eanCode) async {
    //TODO: Consultar Athento o servicio de Newsan
    //return getProductInfoByEANfromArray(eanCode);
    return getProductInfoByEANfromFile(eanCode);
  }

  static Future<ProductInfo> getProductInfoByEANfromArray(String eanCode) async {
    //TODO: Consultar Athento
    return Future<ProductInfo>.delayed(const Duration(milliseconds: 1), () {
      final products= <String, ProductInfo>{
        '1234': ProductInfo(
          EAN: '1234567891012',
          commercialCode: 'TV-LG-80I',
          description: 'Televisor LG 80"',
          retailAccount: '012345',
          lastSell: DateTime(2022, 1, 1),
          lastSellPrice: 123455.56,
          photos: ['frente', 'dorso', 'accesorios', 'embalaje'],
        ),
        '4321': ProductInfo(
          EAN: '25698742224',
          commercialCode: 'AC-BGH-3000',
          description: 'Aire Acondicionado BGH 3000',
          retailAccount: '012345',
          lastSell: DateTime(2022, 1, 1),
          lastSellPrice: 12345.56,
          photos: ['frente', 'dorso', 'accesorios', 'embalaje'],
        ),

      };

      final product = products[eanCode];

      if(product == null){
        throw BusinessException('No se ha encontrado el EAN "$eanCode".');
      }

      return product;

    });
  }

  static Future<ProductInfo> getProductInfoByEANfromFile(String eanCode) async {
    const EAN_INDEX = 0;
    return getProductInfoByEANorCodefromFile(EAN_INDEX, eanCode);

  }

  static Future<ProductInfo> getProductInfoByCommercialCode(String commercialCode) async {
    //TODO: Consultar Athento
    //return getProductInfoByCommercialCodeFromArray(commercialCode);
    return getProductInfoByCommercialCodefromFile(commercialCode);
  }
  static Future<ProductInfo> getProductInfoByCommercialCodeFromArray(String commercialCode) async {
    //TODO: Consultar Athento
    return Future<ProductInfo>.delayed(const Duration(milliseconds: 1), () {
      var products= <String, ProductInfo>{
        'PLANCHA': ProductInfo(
          EAN: '987654321012',
          commercialCode: 'PLANCHA',
          description: 'Plancha 1200 W"',
          retailAccount: '012345',
          lastSellPrice: 2345.56,
          lastSell: DateTime(2018, 1, 1),
          photos: [],
        ),
        'AFEITADORA': ProductInfo(
          EAN: '69415464654',
          commercialCode: 'AFEITADORA',
          description: 'Afeitadora Braun Shower',
          retailAccount: '012345',
          lastSellPrice: 1345.56,
          lastSell: DateTime(2018, 1, 1),
          photos: [],
        )

      };

      var product = products[commercialCode];

      if(product == null){
        throw BusinessException(
            'No se ha encontrado el código comercial "$commercialCode".');
      }

      return product;
    });
  }

  static Future<ProductInfo> getProductInfoByCommercialCodefromFile(String eanCode) async {
    const COMMERCIAL_CODE_INDEX = 1;
    return getProductInfoByEANorCodefromFile(COMMERCIAL_CODE_INDEX, eanCode);

  }

  static Future<ProductInfo> getProductInfoByEANorCodefromFile(int productFileSearchColumnIndex, String productFileSearchKey) async {
    //TODO: Consultar Athento
    const chunkSize = 32 * 1024;


    final producMasterInfo = await getRowAsObjectFromFile(
        fileName: 'products_db.csv' ,
        chunkSize: chunkSize,
        lineSeparator: '\r\n',
        columnSeparator: '\t',
        equals: (List<String> row) => row[productFileSearchColumnIndex] == productFileSearchKey,
        objectBuilder: createProductMasterInfo);

    if(producMasterInfo == null){
      throw BusinessException('No se ha podido encontrar un producto con el código "$productFileSearchKey" en el maestro de productos.');
    }

    const SKU_INDEX = 5;
    const CUIT_INDEX = 10;
    final retailCUIT = (await Cache.getUserInfo()).idNumber;
    final producSalesInfo = await getRowAsObjectFromFile(
        fileName: 'sales_db.csv' ,
        chunkSize: chunkSize,
        lineSeparator: '\r\n',
        columnSeparator: '\t',
        equals: (List<String> row) => row[SKU_INDEX] == producMasterInfo.sku && row[CUIT_INDEX] == retailCUIT,
        objectBuilder: createProductSalesInfo);

    //if(producSalesInfo == null){
    //  throw BusinessException('No se ha podido encontrar un producto con el SKU "${producMasterInfo.sku}" en la base de ventas.');
    //}

    return ProductInfo(
        EAN: producMasterInfo.ean,
        commercialCode: producMasterInfo.commercialCode,
        description: producMasterInfo.description,
        retailAccount: producSalesInfo?.retailAccount,
        lastSell: producSalesInfo?.lastSellDate,
        lastSellPrice: producSalesInfo?.price,
        photos: ['frente', 'dorso', 'accesorios', 'embalaje']);

    //return getProductInfoByEANfromArray(eanCode);


  }

  static Future<TRowObject> getRowAsObjectFromFile<TRowObject>({@required String fileName, @required int chunkSize,
        @required String lineSeparator, @required String columnSeparator, @required bool Function(List<String> row)  equals,
        @required TRowObject objectBuilder(List<String> row)}) async {

    final localFolderPath = (await getApplicationDocumentsDirectory()).path;
    final productsFolderPath = Directory('$localFolderPath/products');

    final productsFile = File('${productsFolderPath.path}/$fileName');

    final productsRndFile = productsFile.openSync(mode: FileMode.read);

    var accumulatedReads = '';
    const start = 0;

    int bytesRead;
    final utf8Decoder = Utf8Decoder(allowMalformed: true);
    do {
      final readBuffer = List<int>.filled(chunkSize, null);

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

  static ProductMasterInfo createProductMasterInfo(List<String> row){
    return ProductMasterInfo.fromCsvRow(row);
  }

  static ProductSalesInfo createProductSalesInfo(List<String> row){
    return ProductSalesInfo.fromCsvRow(row);

  }


  static Future<void> registerNewProductReturn({@required Batch  batch, @required ReturnRequest existingReturnRequest, @required NewReturn newReturn}) async {

    final returnRequestTitle = '${newReturn.EAN}-${newReturn
        .retailReference}'; //TODO: ver qué datos corresponde usar

    /// Si el producto no es auditable, crear la solicitud dentro del lote y guardar la foto opcional (si esta existe)
    if (newReturn.isAuditable == false) {
      // Validar cantidad
      if (newReturn.quantity == null || newReturn.quantity <= 0) {
        throw BusinessException(
            'Los productos no auditables deben tener una cantidad a devolver mayor a cero en lugar de "${newReturn
                .quantity}".');
      }

      // Validar cantidad de fotos
      if (newReturn.photos.length > 1) {
        throw BusinessException(
            'Los productos no auditables deben tener como máximo una foto en lugar de"${newReturn
                .photos.length}".');
      }

      // Obtener valores de campos para la nueva solicitud
      final fieldValues = _getReturnRequestFieldValues(
          returnRequestTitle, batch, newReturn);

      // Validar retailReference. No debería haber otra con el mismo valor
      // Por ahora no validar esto
      //if(newReturn.retailReference?.trim() == existingReturnRequest?.retailReference?.trim()){
      //  throw BusinessException('Ya existe una solicitud de devolución no auditable con la misma referencia interna. Por favor busque esa solicitud y actualice la cantidad');
      //}

      // Crear solicitud con su foto opcional y salir
      // Si no hay fotos
      final configProvider = await  _createConfigProvider(
          _getReturnRequestFieldNameInferenceConfig());
      // Crear solicitud de devolución
      final createdReturnRequestInfo = await SpAthentoServices.createDocument(
          configProvider: configProvider,
          containerUUID: batch.uuid,
          docType: _returnRequestDocType,
          title: returnRequestTitle,
          fieldValues: fieldValues);

      // Si hay fotos a guardar
      if (newReturn.photos.length > 0) { // Ya se validó antes que no sea mayor a una foto
        // Crear foto asociada a la solicitud
        final photoEntry = newReturn.photos.entries.toList()[0];
        final photoName = photoEntry.key;
        final photoPath = photoEntry.value;
        final photoFileExtension = SpFileUtils.getFileExtension(photoPath);
        final configProvider = await  _createConfigProvider(_getPhotoFieldNameInferenceConfig());
        final fieldValues = _getPhotoFieldValues(photoName);
        final photoTitle = '$photoName'; //TODO: En Athento agregar al título de la foto el nro de solicitud???
        final createdPhotoInfo = await SpAthentoServices.createDocumentWithContent(
          configProvider: configProvider,
          containerUUID: createdReturnRequestInfo['uid'],
          docType: _photoDocType,
          title: photoTitle,
          fieldValues: fieldValues,
          content: _getImageByteArray(path: photoPath),
          friendlyFileName: '$photoName$photoFileExtension',
        );

        var foo = createdPhotoInfo;
      }
    }
    /// Si es producto auditable, crear solicitud (si no existe) y crear el documento de producto unitario y documentos de fotos
    else {
      // Validar retail reference.
      // Por ahora no validar esto
      //if(newReturn.retailReference == null || newReturn.retailReference.trim() == ''){
      //  throw BusinessException('La referencia interna no puede ser nula ni blancos.');
      //}

      // Validar cantidad
      if (newReturn.quantity != null) {
        throw BusinessException(
            'No debe indicarse cantidad para los productos auditables. La cantidad indicada es "${newReturn
                .quantity}".');
      }

      // Validar cantidad de fotos
      if (newReturn.photos.length < 1) {
        throw BusinessException(
            'Los productos auditables deben tener al menos foto.');
      }

      // Si no hay solicitud preexistente, crear la solicitud
      String returnRequestUUID;
      String returnRequestNumber;
      if (existingReturnRequest == null) {
        // Obtener valores de campos para la nueva solicitud
        final fieldValues = _getReturnRequestFieldValues(
            returnRequestTitle, batch, newReturn);

        // Las solicitudes de productos auditables no deben tener referencia interna. Esta se asigna a cada producto unitario devuelto.
        fieldValues.removeWhere((fieldName, value) => fieldName == ReturnRequestAthentoFieldName.retailReference);

        final configProvider = await  _createConfigProvider(
            _getReturnRequestFieldNameInferenceConfig());
        // Crear solicitud
        final createdReturnRequestInfo = await SpAthentoServices.createDocument(
          configProvider: configProvider,
          containerUUID: batch.uuid,
          docType: _returnRequestDocType,
          title: returnRequestTitle,
          fieldValues: fieldValues,
        );

        // Recuperar solicitud para obtener el nro de solicitud automático
        returnRequestUUID = createdReturnRequestInfo['uid'];
        final selectFields = [AthentoFieldName.uuid, ReturnRequestAthentoFieldName.requestNumber];
        final foundReturnRequestInfo = await SpAthentoServices.getDocument(configProvider, _returnRequestDocType, returnRequestUUID, selectFields);

        returnRequestNumber = foundReturnRequestInfo[ReturnRequestAthentoFieldName.requestNumber];
      }
      // Tomar valores de la solicitud preexistente
      else {
        returnRequestUUID = existingReturnRequest.uuid;
        returnRequestNumber = existingReturnRequest.requestNumber;

        // Verificar que no haya otro producto con la misma referencia interna dentro de la misma solicitud
        final productConfigProvider = await  _createConfigProvider(_getProductFieldNameInferenceConfig());
        final productSelectFields = [AthentoFieldName.uuid];
        const requestNumberFieldName = '${_productDocType}_${ProductAthentoFieldName.requestNumber}';
        const retailreferenceFieldName = '${_productDocType}_${ProductAthentoFieldName.retailReference}';
        final whereExpression = 'WHERE $requestNumberFieldName = $returnRequestNumber';
        final foundProducts = await SpAthentoServices.findDocuments(productConfigProvider, _productDocType, productSelectFields, whereExpression);

        if (foundProducts.length > 0){
          throw BusinessException('Ya existe un producto con la misma referencia interna "${newReturn.retailReference}" con este mismo EAN.');
        }

      }

      // Crear producto unitario.
      final configProvider = await  _createConfigProvider(
          _getProductFieldNameInferenceConfig());
      final fieldValues = _getProductFieldValues(returnRequestTitle, returnRequestNumber, newReturn);
      final productTitle = '${returnRequestNumber}-${newReturn.EAN}-${newReturn.retailReference}'; //TODO: ver qué título por defecto guardar (para todos los docs en GENERAL)
      final createdProductInfo = await SpAthentoServices.createDocument(
        configProvider: configProvider,
        containerUUID: returnRequestUUID,
        docType: _productDocType,
        title: productTitle,
        fieldValues: fieldValues,
      );

      // Crear fotos asociadas al producto. //TODO: ver cómo manejar los errores asociados a la creación
      newReturn.photos.forEach((String photoName, String photoPath) async {
        final photoTitle = '${newReturn.retailReference}-$photoName';  //TODO: hacer en Athento algo similar
        final photoFileExtension = SpFileUtils.getFileExtension(photoPath);
        final fieldValues = _getPhotoFieldValues(photoName);
        final photoConfigProvider = await  _createConfigProvider(_getPhotoFieldNameInferenceConfig());

        final results = await SpAthentoServices.createDocumentWithContent(
          configProvider: photoConfigProvider,
          containerUUID: createdProductInfo['uid'],
          docType: _photoDocType,
          title: photoTitle,
          fieldValues: fieldValues,
          content: _getImageByteArray(path: photoPath),
          friendlyFileName: '$photoName$photoFileExtension',
        );

        final foo = results['uid'];
      });
    }
  }

  static Map<String, dynamic> _getReturnRequestFieldValues(String returnRequestTitle, Batch batch, NewReturn newReturn) {
    // Obtener valores de campos para la nueva solicitud
    final returnRequest = ReturnRequest(
        title: returnRequestTitle,
        batchNumber: batch.batchNumber,
        EAN: newReturn.EAN,
        commercialCode: newReturn.commercialCode,
        description: newReturn.description,
        retailReference: newReturn.retailReference,
        isAuditable: newReturn.isAuditable,
        quantity: newReturn.quantity
    );
    final fieldValues = returnRequest.toJSON();

    //No enviar el campo autonumérico y el uuid de la solicitud
    fieldValues.removeWhere((key, value) => key == ReturnRequestAthentoFieldName.requestNumber || key == ReturnRequestAthentoFieldName.uuid);
    return fieldValues;
  }

  static Map<String, dynamic> _getProductFieldValues(String productTitle, String requestNumber, NewReturn newReturn) {
    // Obtener valores de campos para la nueva solicitud
    final product = Product(
        requestNumber: requestNumber,
        title: productTitle,
        EAN: newReturn.EAN,
        commercialCode: newReturn.commercialCode,
        description: newReturn.description,
        retailReference: newReturn.retailReference,
    );
    final fieldValues = product.toJSON();

    //No enviar el campo autonumérico y el uuid de la solicitud
    fieldValues.removeWhere((key, value) =>  key == ReturnRequestAthentoFieldName.uuid);
    return fieldValues;
  }


  static Map<String, dynamic>  _getPhotoFieldValues(String photoName) {
    return {
      'tipo_de_foto': photoName,
    };
  }

  static Map<String, String> _getFieldNameInferenceConfig({@required String defaultPrefix}) {
    return  {
      'defaultPrefix': defaultPrefix,
    };
  }

  static Map<String, String> _getBatchFieldNameInferenceConfig() {
    return _getFieldNameInferenceConfig(defaultPrefix: 'lote_lif_');
  }

  static Future<BearerAuthConfigProvider> _createBearerConfigProvider(
      [Map<String, String> fieldNameInferenceConfig]) async {
    final tokenInfo = await Cache.getTokenInfo();
    final token = tokenInfo.token;
    final referer = Configuration.athentoAPIBaseURL;

    final configProvider = BearerAuthConfigProvider(
        Configuration.athentoAPIBaseURL,
        token,
        referer,
        fieldNameInferenceConfig);

    return configProvider;
  }

  static Future<ConfigProvider> _createConfigProvider([Map<String, String>fieldNameInferenceConfig]) async {
    final authenticationType = Configuration.authenticationType;

    ConfigProvider configProvider = null;
    switch(authenticationType){
      case 'basic':
        final userName = await Cache.getUserName();
        final password = await Cache.getUserPassword();
        configProvider = BasicAuthConfigProvider(Configuration.athentoAPIBaseURL, userName , password, fieldNameInferenceConfig);
        break;
      case 'bearer_token':
        configProvider = await  _createBearerConfigProvider(fieldNameInferenceConfig);
        break;
      default:
        throw Exception('Authentication type "$authenticationType" not supported.');
    }

    return configProvider;
  }

  static  Map<String, String> _getReturnRequestFieldNameInferenceConfig() {
    return _getFieldNameInferenceConfig(defaultPrefix: 'solicitud_auditoria_kvg_');
  }

  static  Map<String, String> _getProductFieldNameInferenceConfig() {
    return _getFieldNameInferenceConfig(defaultPrefix: 'producto_wli_');
  }

  static  Map<String, String> _getPhotoFieldNameInferenceConfig() {
    return _getFieldNameInferenceConfig(defaultPrefix: 'foto_oxc_');
  }

  static List<int> _getImageByteArray({@required String path}) {
    final file = File(path);
    return file.readAsBytesSync();
  }

  static Future<List<Product>> getProductsByReturnRequestNumber(String returnRequestNumber) async{
    //Obtener diccionario de inferencia de nombres de campo
    final fieldNameInferenceConfig = _getProductFieldNameInferenceConfig();
    final returnRequestFieldNameInferenceConfig = _getReturnRequestFieldNameInferenceConfig();

    // Obtener config provider para Bearer Token
    final configProvider = await  _createConfigProvider(fieldNameInferenceConfig);

    //Definir campos del SELECT
    final selectFields = [
      AthentoFieldName.uuid,
      AthentoFieldName.title,
      ProductAthentoFieldName.requestNumber,
      ProductAthentoFieldName.EAN,
      ProductAthentoFieldName.commercialCode,
      ProductAthentoFieldName.description,
      ProductAthentoFieldName.retailReference,
    ];


    // Construir WHERE expression
    final parentReturnRequestNumber = ' parent:metadata.${returnRequestFieldNameInferenceConfig['defaultPrefix']}${ReturnRequestAthentoFieldName.requestNumber}';
    final whereExpression = "WHERE ecm:currentLifeCycleState = 'Draft' AND $parentReturnRequestNumber = '$returnRequestNumber'";

    // Invocar a Athento
    final entries = await SpAthentoServices.findDocuments(
        configProvider, _productDocType, selectFields, whereExpression);

    //Convertir resultado a objetos ReturnRequest y retornar resultado
    final returns = entries.map((e) => Product.fromJSON(e));
    return returns.toList();
  }

  static Future <void> deleteBatchByUUID (String batchUuid) async{
    final configProvider = await  _createConfigProvider();
    SpAthentoServices.deleteDocument(configProvider: configProvider, documentUUID: batchUuid);
  }

  static Future <void> updateBatch (Batch batch,String batchreference,String batchdescr,String batchobserv) async{
    final configProvider = await  _createConfigProvider();
    Map<String, dynamic> fieldValues = {
      '${BatchAthentoFieldName.retailReference}': '${batchreference}',
      '${BatchAthentoFieldName.description}': '${batchdescr}',
      '${BatchAthentoFieldName.observation}': '${batchobserv}',
    };
    final title = '${batchreference}-${batchdescr}-${batch.batchNumber}';
    SpAthentoServices.updateDocument(configProvider: configProvider, documentUUID: batch.uuid, title: title, fieldValues: fieldValues);
  }

  static Future <void> updateBatchState (Batch batch) async{
    final configProvider = await  _createConfigProvider();
    Map<String, dynamic> fieldValues = {
      '${AthentoFieldName.state}': 'Enviado'
    };
    final title = '${batch.retailReference}-${batch.description}-${batch.batchNumber}';
    SpAthentoServices.updateDocument(configProvider: configProvider, documentUUID: batch.uuid, title: title, fieldValues: fieldValues);
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

  ProductMasterInfo({ @required this.ean, @required this.commercialCode,
    @required this.sku,@required this.description, @required this.brand,
    @required this.businessUnit, @required this.legalEntity});

  ProductMasterInfo.fromCsvRow(List<String> row) : this(
    ean: row[0],
    commercialCode: row[1],
    sku: row[2],
    description: row[3],
    brand: row[6],
    businessUnit: row[8],
    legalEntity: row[5]
  );
}

class ProductSalesInfo{
  String sku;
  DateTime lastSellDate;
  double price;
  String retailAccount;

  ProductSalesInfo({ @required this.sku, @required this.lastSellDate, @required this.price, @required this.retailAccount});

  ProductSalesInfo.fromCsvRow(List<String> row) : this(
      sku: row[5],
      lastSellDate: _parseDate(row[0]),
      price: double.parse(row[14].replaceFirst(',', '.')) ,
      retailAccount: row[8],
  );

  static DateTime _parseDate(String dateString){
    final rx = RegExp(r'(\d+)/(\d+)\/(\d+)');
    final match = rx.firstMatch(dateString);
    if(match != null) { //Formato dd/mm/yyyy
      dateString = '${match.group(3)}-${match.group(2)}-${match.group(1)}';
    }

    return DateTime.parse(dateString);
  }
}
