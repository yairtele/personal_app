import 'package:flutter/cupertino.dart';
import 'package:navigation_app/config/cache.dart';
import 'package:navigation_app/config/configuration.dart';
import 'package:navigation_app/services/athento/bearer_auth_config_provider.dart';
import 'package:navigation_app/services/athento/sp_athento_services.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/return_request.dart';
import 'package:navigation_app/services/business/business_service_exception.dart';
import 'package:navigation_app/services/business/product.dart';
import '../newsan_services.dart';

class BusinessServices {
  static const String _batchDocType = 'lote_lif';

  static Future<UserInfo> getUserInfo(String userNameOrUUID) async {
    final configProvider = await _getBearerConfigProvider();
    return SpAthentoServices.getUserInfo(configProvider, userNameOrUUID);
  }

  static Future<String> getCompanyName(String cuit) async {
    return NewsanServices.getCompanyInfo(cuit);
  }

  static Future<void> createBatch(Batch batch) async {
    final fieldNameInferenceConfig = _getBatchFieldNameInferenceConfig();

    final configProvider =
        await _getBearerConfigProvider(fieldNameInferenceConfig);

    //TODO: ver cómo obtener el id del espacio.
    //TODO: DIRECTAMENTE CONSUKLTAR SIN containerUUID (nosotros deberíamos tener un usuario retail para saber buscar nuestras pruebas).
    const containerUUID = '5366d23d-07bb-4eb3-b34a-5943b0f5cccf';

    final title = batch.retailReference +
        ' - ' +
        batch
            .description; // Se supone que Athento asigna nombre automáticamente, pero por las dudas...
    final fieldValues = batch.toJSON();

    await SpAthentoServices.createDocument(
        configProvider, containerUUID, _batchDocType, title, fieldValues);
  }

  static Map<String, String> _getBatchFieldNameInferenceConfig() {
    const fieldNameInferenceConfig = {
      'defaultPrefix': 'lote_lif_',
    };
    return fieldNameInferenceConfig;
  }

  static Future<BearerAuthConfigProvider> _getBearerConfigProvider(
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

  static Future<List<Batch>> getBatches() async {
    final fieldNameInferenceConfig = _getBatchFieldNameInferenceConfig();
    final configProvider =
        await _getBearerConfigProvider(fieldNameInferenceConfig);
    final selectFields = [
      'ecm:uuid',
      'dc:title',
      BatchAthentoFieldName.retailReference,
      BatchAthentoFieldName.description,
      BatchAthentoFieldName.cuitRetail,
      BatchAthentoFieldName.retailCompanyName,
    ];

    const whereExpression = "WHERE ecm:currentLifeCycleState = 'Draft'";

    final entries = await SpAthentoServices.findDocuments(
        configProvider, _batchDocType, selectFields, whereExpression);
    final batches = entries.map((e) => Batch.fromJSON(e));
    return batches.toList();
  }
 //TODO: Completar armado de metadatos del formulario Solicitudes
  static Future<List<Batch>> getReturns() async {
    final fieldNameInferenceConfig = _getBatchFieldNameInferenceConfig();
    final configProvider = await _getBearerConfigProvider(fieldNameInferenceConfig);
    final selectFields = [
      'ecm:uuid',
      'dc:title',
      ReturnAthentoFieldName.retailReference,
      ReturnAthentoFieldName.cantidad,
    ];

    const whereExpression = "WHERE ecm:currentLifeCycleState = 'Draft'";

    final entries = await SpAthentoServices.findDocuments(
        configProvider, _batchDocType, selectFields, whereExpression);
    final returns = entries.map((e) => Batch.fromJSON(e));
    return returns.toList();
  }



  static Future<Product> getProductByEAN(String eanCode) {
    //TODO: Consultar Athento
    return Future<Product>.delayed(const Duration(milliseconds: 1), () {
      if (eanCode != '1234') {
        throw BusinessServiceException('No se ha encontrado el EAN "$eanCode".');
      }

      return Product(
          EAN: '1234567891012',
          commercialCode: 'TV-LG-80I',
          description: 'Televisor LG 80"',
          lastSell: DateTime(2022, 1, 1),
          photos: ['Frente', 'Dorso', 'Accesorios', 'Embalaje']);
    });
  }

  static Future<Product> getProductByCommercialCode(String commercialCode) {
    //TODO: Consultar Athento
    return Future<Product>.delayed(const Duration(milliseconds: 1), () {
      if (commercialCode != 'PROD') {
        throw BusinessServiceException('No se ha encontrado el código comercial "$commercialCode".');
      }
      return Product(
          EAN: '1234567891012',
          commercialCode: 'PROD-LG-80I',
          description: 'Televisor LG 80"',
          lastSell: DateTime(2018, 1, 1),
          photos: []);
    });
  }
}
