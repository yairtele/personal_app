import 'dart:io';

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

class BusinessServices {
  static const String _batchDocType = 'lote_lif';
  static const String _returnRequestDocType = 'solicitud_auditoria_kvg';
  static const String _productDocType = 'producto_wli';
  static const String _photoDocType = 'foto_oxc';


  static Future<void> updateBatch(String uuid) async{

  }
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
    final batchNumberFieldName = '${fieldNameInferenceConfig['defaultPrefix']}${ReturnRequestAthentoFieldName.batchNumber}';
    final whereExpression = "WHERE ecm:currentLifeCycleState = 'Draft' AND $batchNumberFieldName = '$batchNumber'";

    // Invocar a Athento
    final entries = await SpAthentoServices.findDocuments(
        configProvider, _returnRequestDocType, selectFields, whereExpression);

    //Convertir resultado a objetos ReturnRequest y retornar resultado
    final returns = entries.map((e) => ReturnRequest.fromJSON(e));
    return returns.toList();
  }

  static Future<ProductInfo> getProductInfoByEAN(String eanCode) {
    //TODO: Consultar Athento
    return Future<ProductInfo>.delayed(const Duration(milliseconds: 1), () {
      if (eanCode != '1234') {
        throw BusinessException('No se ha encontrado el EAN "$eanCode".');
      }

      return ProductInfo(
        EAN: '1234567891012',
        commercialCode: 'TV-LG-80I',
        description: 'Televisor LG 80"',
        lastSell: DateTime(2022, 1, 1),
        photos: ['frente', 'dorso', 'accesorios', 'embalaje'],
      );
    });
  }

  static Future<ProductInfo> getProductInfoByCommercialCode(String commercialCode) {
    //TODO: Consultar Athento
    return Future<ProductInfo>.delayed(const Duration(milliseconds: 1), () {
      if (commercialCode != 'PROD') {
        throw BusinessException(
            'No se ha encontrado el código comercial "$commercialCode".');
      }
      return ProductInfo(
        EAN: '1234567891012',
        commercialCode: 'PROD-LG-80I',
        description: 'Televisor LG 80"',
        lastSell: DateTime(2018, 1, 1),
        photos: [],
      );
    });
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
      // Validar retail reference. //TODO: verificar que no exista otro producto dentro de esta solicitud con el mismo retail Reference
      if(newReturn.retailReference == null || newReturn.retailReference.trim() == ''){
        throw BusinessException('La referencia interna no puede ser nula ni blancos.');
      }

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
        final whereExpression = 'WHERE $requestNumberFieldName = $returnRequestNumber AND $retailreferenceFieldName = ${newReturn.retailReference}';
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
    final returnRequestNumberFieldName = '${fieldNameInferenceConfig['defaultPrefix']}${ProductAthentoFieldName.requestNumber}';
    final whereExpression = "WHERE ecm:currentLifeCycleState = 'Draft' AND $returnRequestNumberFieldName = $returnRequestNumber";

    // Invocar a Athento
    final entries = await SpAthentoServices.findDocuments(
        configProvider, _productDocType, selectFields, whereExpression);

    //Convertir resultado a objetos ReturnRequest y retornar resultado
    final returns = entries.map((e) => Product.fromJSON(e));
    return returns.toList();
  }



}


