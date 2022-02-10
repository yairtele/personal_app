import 'package:flutter/cupertino.dart';
import 'package:navigation_app/config/cache.dart';
import 'package:navigation_app/config/configuration.dart';
import 'package:navigation_app/services/athento/bearer_auth_config_provider.dart';
import 'package:navigation_app/services/athento/sp_athento_services.dart';
import '../newsan_services.dart';


class BusinessServices {

  static const String _batchDocType = 'lote_lif';

  static Future<UserInfo> getUserInfo(String userNameOrUUID) async{
    final  configProvider = await _getBearerConfigProvider();
    return SpAthentoServices.getUserInfo(configProvider, userNameOrUUID);
  }
  
  static Future<String> getCompanyName(String cuit) async{
    return NewsanServices.getCompanyInfo(cuit);
  }

  static Future<void> createBatch(Batch batch) async {
    final fieldNameInferenceConfig = _getBatchFieldNameInferenceConfig();

    final configProvider = await _getBearerConfigProvider(fieldNameInferenceConfig);

    //TODO: ver cómo obtener el id del espacio
    const containerUUID = '5366d23d-07bb-4eb3-b34a-5943b0f5cccf';

    final title = batch.retailReference + ' - ' + batch.description; // Se supone que Athento asigna nombre automáticamente, pero por las dudas...
    final fieldValues =  batch.toJSON();

    await SpAthentoServices.createDocument(configProvider, containerUUID, _batchDocType, title, fieldValues);
  }

  static Map<String, String> _getBatchFieldNameInferenceConfig() {
    const fieldNameInferenceConfig = {
      'defaultPrefix': 'lote_lif_',
    };
    return fieldNameInferenceConfig;
  }


  static Future<BearerAuthConfigProvider> _getBearerConfigProvider([Map<String, String> fieldNameInferenceConfig]) async{
    final tokenInfo = await Cache.getTokenInfo();
    final token = tokenInfo.token;
    final referer = Configuration.athentoAPIBaseURL;

    final configProvider = BearerAuthConfigProvider(Configuration.athentoAPIBaseURL, token, referer, fieldNameInferenceConfig);

    return configProvider;
  }

  static Future<List<Batch>> getBatches() async{
    final fieldNameInferenceConfig = _getBatchFieldNameInferenceConfig();
    final configProvider = await _getBearerConfigProvider(fieldNameInferenceConfig);
    final selectFields = [
      'ecm:uuid',
      'dc:title',
      BatchAthentoFieldName.retailReference,
      BatchAthentoFieldName.description,
      BatchAthentoFieldName.cuitRetail,
      BatchAthentoFieldName.razonSocialRetail,
    ];

    const whereExpression = "WHERE ecm:currentLifeCycleState = 'Draft'";

    final entries = await SpAthentoServices.findDocuments(configProvider, _batchDocType, selectFields, whereExpression);
    final batches = entries.map((e) => Batch.fromJSON(e) );
    return batches.toList();
  }

}

class Batch {
  String retailReference;
  String description;
  String cuitRetail;
  String razonSocialRetail;

  //TODO: validar uno de this.retailReference o this.description no sean vacíos ni nulos
  Batch({this.retailReference, this.description, @required this.cuitRetail, @required this.razonSocialRetail});

  Map<String, dynamic> toJSON() {
    return {
      BatchAthentoFieldName.retailReference: retailReference,
      BatchAthentoFieldName.description: description,
      BatchAthentoFieldName.cuitRetail: cuitRetail,
      BatchAthentoFieldName.razonSocialRetail: razonSocialRetail
    };
  }

  Batch.fromJSON(Map<String, dynamic> json){
    retailReference = json[BatchAthentoFieldName.retailReference];
    description = json[BatchAthentoFieldName.description];
    cuitRetail = json[BatchAthentoFieldName.cuitRetail];
    razonSocialRetail = json[BatchAthentoFieldName.razonSocialRetail];
  }
}

class BatchAthentoFieldName{
  static const String retailReference = 'referencia_interna_lote';
  static const String description = 'descripcion_lote';
  static const String cuitRetail = 'cuit_cliente';
  static const String razonSocialRetail = 'razon_social';
}