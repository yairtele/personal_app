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

  static Future<Map<String, dynamic>> createBatch(Batch batch) async {
    final fieldNameInferenceConfig = _getBatchFieldNameInferenceConfig();

    final configProvider = await  _createConfigProvider(fieldNameInferenceConfig);

    //TODO: ver cómo obtener el id del espacio.
    //TODO: DIRECTAMENTE CONSUKLTAR SIN containerUUID (nosotros deberíamos tener un usuario retail para saber buscar nuestras pruebas).

    final title = '${batch.retailReference}-${batch.description}'; // Se supone que Athento asigna nombre automáticamente, pero por las dudas...
    final fieldValues = batch.toJSON();

    //No enviar el campo autonumérico del Lote
    fieldValues.removeWhere(
            (key, value) => key == BatchAthentoFieldName.batchNumber ||
                            key == BatchAthentoFieldName.uuid
    );

    final response = await SpAthentoServices.createDocument( configProvider: configProvider,
        containerUUID: null,
        docType: _batchDocType,
        title: title,
        fieldValues: fieldValues
    );
    return response;
  }

  static Future<List<Batch>> getRetailActiveBatches() async {
    final fieldNameInferenceConfig = _getBatchFieldNameInferenceConfig();
    final configProvider =
        await  _createConfigProvider(fieldNameInferenceConfig);
    final selectFields = [
      BatchAthentoFieldName.uuid,
      BatchAthentoFieldName.state,
      BatchAthentoFieldName.title,
      BatchAthentoFieldName.state,
      BatchAthentoFieldName.batchNumber,
      BatchAthentoFieldName.retailReference,
      BatchAthentoFieldName.description,
      BatchAthentoFieldName.cuitRetail,
      BatchAthentoFieldName.retailCompanyName,
      BatchAthentoFieldName.observation,
    ];

    final whereExpression = "WHERE ecm:currentLifeCycleState in ('${BatchStates.Draft}','${BatchStates.EnProceso}','${BatchStates.Enviado}','${BatchStates.InfoEnviada}','${BatchStates.InfoPendiente}')";

    final entries = await SpAthentoServices.findDocuments(
        configProvider, _batchDocType, selectFields, whereExpression);
    final batches = entries.map((e) => Batch.fromJSON(e));
    return batches.toList();
  }

  static Future<List<ReturnRequest>> getReturnRequestsByBatchUUID({required String batchUUID}) async {
    //Obtener diccionario de inferencia de nombres de campo
    final fieldNameInferenceConfig = _getReturnRequestFieldNameInferenceConfig();

    // Obtener config provider para Bearer Token
    final configProvider = await  _createConfigProvider(fieldNameInferenceConfig);

    //Definir campos del SELECT
    final selectFields = [
      AthentoFieldName.uuid,
      AthentoFieldName.state,
      AthentoFieldName.title,
      ReturnRequestAthentoFieldName.requestNumber,
      ReturnRequestAthentoFieldName.batchNumber,
      ReturnRequestAthentoFieldName.EAN,
      ReturnRequestAthentoFieldName.sku,
      ReturnRequestAthentoFieldName.commercialCode,
      ReturnRequestAthentoFieldName.description,
      ReturnRequestAthentoFieldName.retailReference,
      ReturnRequestAthentoFieldName.quantity,
      ReturnRequestAthentoFieldName.isAuditable,
      ReturnRequestAthentoFieldName.legalEntity,
      ReturnRequestAthentoFieldName.lastSell,
      ReturnRequestAthentoFieldName.price,
      ReturnRequestAthentoFieldName.businessUnit
    ];

    // Construir WHERE expression
    //final parentBatchNumber = ' parent:metadata.${batchFieldNameInferenceConfig['defaultPrefix']}${BatchAthentoFieldName.batchNumber}';
    //final whereExpression = "WHERE ecm:currentLifeCycleState = 'Draft' AND $parentBatchNumber = '$batchNumber'";
    final whereExpression = "WHERE ecm:parentId = '$batchUUID'";

    // Invocar a Athento
    final entries = await SpAthentoServices.findDocuments(
        configProvider, _returnRequestDocType, selectFields, whereExpression);

    //Convertir resultado a objetos ReturnRequest y retornar resultado
    final returns = entries.map((e) => ReturnRequest.fromJSON(e));
    return returns.toList();
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
  }//TODO: YAYO: Comentar cuando se habilite ws

  static ProductSalesInfo _createProductSalesInfo(List<String> row){
    return ProductSalesInfo.fromCsvRow(row);
  }//TODO: YAYO: Comentar cuando se habilite ws

  static ProductAuditRules _createProductAuditRules(List<String> row){
    return ProductAuditRules.fromCsvRow(row);
  }

  static Future<void> registerNewProductReturn({required Batch  batch, required ReturnRequest? existingReturnRequest, required NewReturn newReturn}) async {

    final returnRequestTitle = '${newReturn.EAN}-${newReturn.retailReference}'; //TODO: ver qué datos corresponde usar

    /// Si el producto no es auditable, crear la solicitud dentro del lote y guardar la foto opcional (si esta existe)
    if (newReturn.isAuditable == false) {
      // Validar cantidad
      if (newReturn.quantity == null || newReturn.quantity! <= 0) {
        throw BusinessException(
            'Los productos no auditables deben tener una cantidad a devolver mayor a cero en lugar de "${newReturn.quantity}".');
      }

      // Validar cantidad de fotos
      if (newReturn.photos.length > 1) {
        throw BusinessException(
            'Los productos no auditables deben tener como máximo una foto en lugar de"${newReturn.photos.length}".');
      }

      // Obtener valores de campos para la nueva solicitud
      final fieldValues = _getReturnRequestFieldValues(returnRequestTitle, batch, newReturn);

      // Validar retailReference. No debería haber otra con el mismo valor
      // Por ahora no validar esto
      //if(newReturn.retailReference?.trim() == existingReturnRequest?.retailReference?.trim()){
      //  throw BusinessException('Ya existe una solicitud de devolución no auditable con la misma referencia interna. Por favor busque esa solicitud y actualice la cantidad');
      //}

      // Crear solicitud con su foto opcional y salir
      // Si no hay fotos
      final configProvider = await  _createConfigProvider(_getReturnRequestFieldNameInferenceConfig());
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
        final returnPhoto = photoEntry.value;
        final photoFileExtension = SpFileUtils.getFileExtension(returnPhoto.path);
        final configProvider = await  _createConfigProvider(_getPhotoFieldNameInferenceConfig());
        final fieldValues = _getPhotoFieldValues(photoName, returnPhoto.isDummy);
        final photoTitle = '$photoName'; //TODO: En Athento agregar al título de la foto el nro de solicitud???
        final createdPhotoInfo = await SpAthentoServices.createDocumentWithContent(
          configProvider: configProvider,
          containerUUID: createdReturnRequestInfo['uid'],
          docType: _photoDocType,
          title: photoTitle,
          fieldValues: fieldValues,
          content: _getImageByteArray(path: returnPhoto.path),
          friendlyFileName: '$photoName$photoFileExtension',
        );
      }
    }
    /// Si es producto auditable, crear solicitud (si no existe) y crear el documento de producto unitario y documentos de fotos
    else {
      // Validar retail reference.
      if(newReturn.retailReference.trim() == ''){
        throw BusinessException('La referencia interna no puede ser nula ni blancos.');
      }

      // Validar cantidad
      if (newReturn.quantity != null) {
        throw BusinessException(
            'No debe indicarse cantidad para los productos auditables. La cantidad indicada es "${newReturn
                .quantity}".');
      }

      // Validar cantidad de fotos
      if (!newReturn.photos.values.any((photo) => photo.isDummy == false)) {
        throw BusinessException(
            'Los productos auditables deben tener al menos foto.');
      }

      // Si no hay solicitud preexistente, crear la solicitud
      String returnRequestUUID;
      String? returnRequestNumber;
      if (existingReturnRequest == null) {
        // Obtener valores de campos para la nueva solicitud
        final fieldValues = _getReturnRequestFieldValues(
            returnRequestTitle, batch, newReturn);

        // Las solicitudes de productos auditables no deben tener referencia interna. Esta se asigna a cada producto unitario devuelto.
        fieldValues.removeWhere((fieldName, value) => fieldName == ReturnRequestAthentoFieldName.retailReference || fieldName == ReturnRequestAthentoFieldName.observations);

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
        returnRequestNumber = null;
      }
      // Tomar valores de la solicitud preexistente
      else {
        returnRequestUUID = existingReturnRequest.uuid!;
        returnRequestNumber = existingReturnRequest.requestNumber;
        // Verificar que no haya otro producto con la misma referencia interna dentro de la misma solicitud
        final productConfigProvider = await  _createConfigProvider(_getProductFieldNameInferenceConfig());
        final productSelectFields = [AthentoFieldName.uuid];
        const retailreferenceFieldName = '${_productDocType}_${ProductAthentoFieldName.retailReference}';
        final whereExpression = "WHERE ecm:parentId = '$returnRequestUUID' AND $retailreferenceFieldName = '${newReturn.retailReference.trim()}'";
        final foundProducts = await SpAthentoServices.findDocuments(productConfigProvider, _productDocType, productSelectFields, whereExpression);

        if (foundProducts.length > 0){
          throw BusinessException('Ya existe un producto con la misma referencia interna "${newReturn.retailReference}" para este mismo EAN.');
        }

      }

      // Crear producto unitario.
      final configProvider = await  _createConfigProvider(
          _getProductFieldNameInferenceConfig());
      final fieldValues = _getProductFieldValues(returnRequestTitle,  newReturn);
      final productTitle = '${returnRequestNumber}-${newReturn.EAN}-${newReturn.retailReference}'; //TODO: ver qué título por defecto guardar (para todos los docs en GENERAL)
      final createdProductInfo = await SpAthentoServices.createDocument(
        configProvider: configProvider,
        containerUUID: returnRequestUUID,
        docType: _productDocType,
        title: productTitle,
        fieldValues: fieldValues,
      );

      // Crear fotos asociadas al producto. //TODO: ver cómo manejar los errores asociados a la creación
      newReturn.photos.forEach((String photoName, ReturnPhoto returnPhoto) async {
        final photoTitle = '${newReturn.retailReference}-$photoName';  //TODO: hacer en Athento algo similar
        final photoFileExtension = SpFileUtils.getFileExtension(returnPhoto.path);
        final fieldValues = _getPhotoFieldValues(photoName, returnPhoto.isDummy);
        final photoConfigProvider = await  _createConfigProvider(_getPhotoFieldNameInferenceConfig());

        final createdPhotoInfo = await SpAthentoServices.createDocumentWithContent(
          configProvider: photoConfigProvider,
          containerUUID: createdProductInfo['uid'],
          docType: _photoDocType,
          title: photoTitle,
          fieldValues: fieldValues,
          content: _getImageByteArray(path: returnPhoto.path),
          friendlyFileName: '$photoName$photoFileExtension',
        );
      });
    }
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

  static Future<BearerAuthConfigProvider> _createBearerConfigProvider(
      [Map<String, String>? fieldNameInferenceConfig]) async {
    final tokenInfo = (await Cache.getTokenInfo())!;
    final token = tokenInfo.token;
    final referer = Configuration.athentoAPIBaseURL;

    final configProvider = BearerAuthConfigProvider(
        Configuration.athentoAPIBaseURL,
        token,
        referer,
        fieldNameInferenceConfig);

    return configProvider;
  }

  static Future<ConfigProvider> _createConfigProvider([Map<String, String>? fieldNameInferenceConfig]) async {
    final authenticationType = Configuration.authenticationType;

    ConfigProvider configProvider;
    switch(authenticationType){
      case 'basic':
        final userName = (await Cache.getUserName())!;
        final password = (await Cache.getUserPassword())!;
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

  static Future<List<Product>> getProductsByReturnRequestUUID(String returnRequestUUID) async{
    //Obtener diccionario de inferencia de nombres de campo
    final fieldNameInferenceConfig = _getProductFieldNameInferenceConfig();

    // Obtener config provider para Bearer Token
    final configProvider = await  _createConfigProvider(fieldNameInferenceConfig);

    //Definir campos del SELECT
    final selectFields = [
      AthentoFieldName.uuid,
      AthentoFieldName.state,
      AthentoFieldName.title,
      ProductAthentoFieldName.requestNumber,
      ProductAthentoFieldName.EAN,
      ProductAthentoFieldName.commercialCode,
      ProductAthentoFieldName.description,
      ProductAthentoFieldName.retailReference,
    ];


    // Construir WHERE expression
    //final whereExpression = "WHERE ecm:currentLifeCycleState = ${BatchStates.Draft} AND ecm:parentId = '$returnRequestUUID'";
    final whereExpression = "WHERE ecm:parentId = '$returnRequestUUID'";
    // Invocar a Athento
    final entries = await SpAthentoServices.findDocuments(
        configProvider, _productDocType, selectFields, whereExpression);

    //Convertir resultado a objetos ReturnRequest y retornar resultado
    final returns = entries.map((e) => Product.fromJSON(e));
    return returns.toList();
  }

  static Future<Map<String, PhotoDetail>> getPhotosByProductUUID(String productUuid) async{
    //Obtener diccionario de inferencia de nombres de campo
    final fieldNameInferenceConfig = _getPhotoFieldNameInferenceConfig();
    //final returnRequestFieldNameInferenceConfig = _getProductFieldNameInferenceConfig();

    // Obtener config provider para Bearer Token
    final configProvider = await  _createConfigProvider(fieldNameInferenceConfig);

    //Definir campos del SELECT
    final selectFields = [
      ProductPhotoAthentoFieldName.uuid,
      ProductPhotoAthentoFieldName.state,
      ProductPhotoAthentoFieldName.title,
      ProductPhotoAthentoFieldName.photoType,
      ProductPhotoAthentoFieldName.isDummy
    ];

    // Construir WHERE expression
    final whereExpression = "WHERE ecm:parentId = '$productUuid'";

    // Invocar a Athento
    final entries = await SpAthentoServices.findDocuments(configProvider, _photoDocType, selectFields, whereExpression);

    //Convertir resultado a objetos ReturnRequest y retornar resultado
    final productPhotos = entries.map((e) => ProductPhoto.fromJSON(e)).toList();

    final takenPictures = <String, PhotoDetail>{};

    //if (productPhotos.length == 0){
    //  takenPictures['otra'] = PhotoDetail(content: null, isDummy: true);
    //} else {
      for (final photo in productPhotos){

        final content = await SpAthentoServices.getContentAsBytes(configProvider: configProvider, documentUUID: photo.uuid);

        takenPictures[photo.label] = PhotoDetail(
          uuid: photo.uuid,
          content: await SpProductUtils.binaryFileInfo2XFile(content, photo.label, productUuid, photo.uuid),
          isDummy: photo.isDummy,
          state: photo.state,
          hasChanged: false
        );
      }
    //}
    return takenPictures;
  }

  //TODO: analizar la salida de deleteDocument y ver cómo manejarla y qué devolver y si hay que usar await
  static Future <void> deleteBatchByUUID (String batchUuid) async{
    final configProvider = await  _createConfigProvider();
    await SpAthentoServices.deleteDocument(configProvider: configProvider, documentUUID: batchUuid);
  }

  //TODO: analizar la salida de updateDocument y ver cómo manejarla y qué devolver y si hay que usar await
  static Future <void> updateBatch (Batch batch,String batchreference,String batchdescr,String batchobserv) async{
    final configProvider = await  _createConfigProvider();
    Map<String, dynamic> fieldValues = {
      '${BatchAthentoFieldName.retailReference}': '${batchreference}',
      '${BatchAthentoFieldName.description}': '${batchdescr}',
      '${BatchAthentoFieldName.observation}': '${batchobserv}',
    };
    final title = '${batchreference}-${batchdescr}-${batch.batchNumber}';
    await SpAthentoServices.updateDocument(configProvider: configProvider, documentUUID: batch.uuid!, title: title, fieldValues: fieldValues);
  }

  //TODO: analizar la salida de _updateBatchState y ver cómo manejarla y qué devolver y si hay que usar await
  static Future <void> sendBatchToAudit (Batch batch) async{
    await _updateBatchState(batch.uuid!, 'Enviado');
  }

  //TODO: analizar la salida de SpAthentoServices.updateDocument y ver cómo manejarla y qué devolver y si hay que usar await
  static Future <void> _updateBatchState (String batchUUID, String lifeCycleState) async{
    final configProvider = await  _createConfigProvider();
    final fieldValues = {
      '${AthentoFieldName.state}': lifeCycleState
    };
    await SpAthentoServices.updateDocument(configProvider: configProvider, documentUUID: batchUUID,  fieldValues: fieldValues);
  }

  //TODO: analizar la salida de SpAthentoServices.deleteDocument y ver cómo manejarla y qué devolver y si hay que usar await
  static Future <void> deleteReqReturnByUUID (String ReqReturnUuid) async{
    final configProvider = await  _createConfigProvider();
    await SpAthentoServices.deleteDocument(configProvider: configProvider, documentUUID: ReqReturnUuid);
  }

  //TODO: los parámetros String returnEAN,String returnreference,String returndescr,String returnunities ya están en el ReturnRequest
  static Future <void> updateRequestReturn (ReturnRequest requestReturn, String returnEAN, String returnReference, String returnDescr, String returnunities,  Map<String, PhotoDetail> photos) async{
    final configProvider = await  _createConfigProvider();
    final fieldValues = {
      '${ReturnRequestAthentoFieldName.EAN}': '${returnEAN}',
      '${ReturnRequestAthentoFieldName.retailReference}': '${returnReference}',
      '${ReturnRequestAthentoFieldName.description}': '${returnDescr}',
      '${ReturnRequestAthentoFieldName.quantity}': '${returnunities}',
    };
    //TODO:Armado con orden correcto del titulo para la solicitud.
    await SpAthentoServices.updateDocument(configProvider: configProvider, documentUUID: requestReturn.uuid!, fieldValues: fieldValues);

    await _updatePhotos(configProvider, photos);

    // Delete cached images
    await _deletePhotoCacheDirectory(requestReturn.uuid!);
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

  static Future <void> updateProduct (bool referenceModified, String reference,
      Map<String, PhotoDetail> photos, Product product) async {

    // Validar que al menos una foto (modificada o no) no sea dummy
    if(!photos.values.any((photoDetail) => photoDetail.isDummy == false)){
      throw BusinessException('Se debe cargar al menos una foto.');
    }

    //Obtener fotos modificadas
    final changedPhotos = Map<String, PhotoDetail>.fromEntries(photos.entries
        .where((entry) => entry.value.hasChanged == true));


    final configProvider = await  _createConfigProvider();

    if(referenceModified) {
      final  fieldValues = {
        ProductAthentoFieldName.retailReference: reference
      };

      await SpAthentoServices.updateDocument(configProvider: configProvider,
          documentUUID: product.uuid!,
          fieldValues: fieldValues);
    }

    await _updatePhotos(configProvider, changedPhotos);

    // Delete cached images
    await _deletePhotoCacheDirectory(product.uuid!);

  }

  static Future<void> _updatePhotos(ConfigProvider configProvider, Map<String, PhotoDetail> photos) async {
    for(final entry in photos.entries) {
        final photoName = entry.key;
        final photoDetail = entry.value;
        final photoFileExtension = SpFileUtils.getFileExtension(photoDetail.content.path);

        // Actualizar binario
        await SpAthentoServices.updateDocumentContent(
            configProvider: configProvider,
            documentUUID: photoDetail.uuid,
            content: await photos[photoName]!.content.readAsBytes(),
            friendlyFileName: '$photoName$photoFileExtension'
        );

        // Actualizar metadatos
        final photoState = photoDetail.state == BatchStates.InfoPendiente && photoDetail.isDummy == false ? BatchStates.InfoEnviada : photoDetail.state;

        final fieldValues = {
          if (photoState == BatchStates.InfoEnviada)
            AthentoFieldName.state: photoState,
          ProductPhotoAthentoFieldName.isDummy: photoDetail.isDummy
        };

        await SpAthentoServices.updateDocument(
            configProvider: configProvider,
            documentUUID: photoDetail.uuid,
            fieldValues: fieldValues);

        //_silentlyDeleteFile(photoDetail.content.path);
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

  //TODO: analizar la salida de SpAthentoServices.deleteDocument y ver cómo manejarla y qué devolver y si hay que usar await
  static Future <void> deleteProductByUUID (String productUUID) async {
    final configProvider = await  _createConfigProvider();
    await SpAthentoServices.deleteDocument(configProvider: configProvider, documentUUID: productUUID);
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