import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:navigation_app/config/configuration.dart';
import 'package:navigation_app/services/athento/athento_endpoint.dart';
import 'package:navigation_app/services/athento/basic_auth_config_provider.dart';
import 'package:navigation_app/services/sp_ws.dart';
import 'config_provider.dart';

class SpAthentoServices {
  static Future<UserInfo> getUserInfo(ConfigProvider configProvider,
      String user_name_or_uuid) async {
    final uri = configProvider.getEndpointUrl(AthentoEndpoint.getUserInfo);
    final headers = configProvider.getHttpHeaders();

    final response = await SpWS.get(uri, headers: headers, parameters: {});

    final userInfo = UserInfo.fromJSON(jsonDecode(response.body));
    if (userInfo.idNumber == '') {
      throw Exception(
          'El usuario $user_name_or_uuid no tiene el CUIT de retailer cargado en su perfil de Athento');
    }

    return userInfo;
  }

  static Future<TokenInfo> getAuthenticationToken(
      BasicAuthConfigProvider configProvider, String userName, String password) async {
    //TODO: usar SpWS en lugar de http directo.

    final requestBody = {
      'grant_type': 'password',
      'username': userName,
      'password': password,
      'client_id': Configuration.athentoClientId,
      'client_secret': Configuration.athentoClientSecret,
      'scope': 'write',
    };


    final parameters = Map<String, String>();
    /*final parameters = {
      'grant_type': 'password',
      'username': Configuration.athentoUser,
      'password': Configuration.athentoPassword,
      'client_id': Configuration.athentoClientId,
      'client_secret': Configuration.athentoClientSecret,
      'scope': 'write',
    };*/
    final headers = configProvider.getHttpHeaders({
      'Content-Type': 'application/x-www-form-urlencoded'
    });

    headers.remove('Authorization');

    final response = await SpWS.post(
        configProvider.getEndpointUrl(AthentoEndpoint.getAuthToken),
        parameters: parameters,
        headers: headers,
        body: requestBody
    );

    final jsonResponse = jsonDecode(response.body);
    return TokenInfo.fromJSON(jsonResponse);
  }

  static Future<Map<String, dynamic>> createDocument(
      ConfigProvider configProvider,
      String containerUUID, String docType, String title,
      Map<String, dynamic> fieldValues, [String auditMessage = '']) async {
    final renamedFieldValues = configProvider.getFieldValues(
        title, fieldValues);

    final jsonRequestBody = {
      'input': containerUUID,
      'params': {
        'type': docType,
        'audit': auditMessage,
        'properties': renamedFieldValues,
      }
    };

    final headers = configProvider.getHttpHeaders();

    //console.log("endpoint: " + configProvider.getServiceUrl() + "Athento.DocumentCreate/");
    //console.log(JSON.stringify(jsonRequestBody));
    final response = await SpWS.post(configProvider.serviceBaseUrl +
        configProvider.getEndpointUrl('createDocument'), parameters: {},
        headers: headers,
        body: jsonRequestBody);

    //console.log("response.status: " + response.statusCode);
    //console.log("response.body: " + response.body);

    return configProvider.parseResponse(response.body);
  }
  static String _getFirstWord(String inputString) {
    final wordList = inputString.split('');
    return wordList.isNotEmpty ? wordList[0] : '';
  }

  static Future<Map<String, dynamic>> getDocument(ConfigProvider configProvider, String docType,
      String documentUUID, List<String> selectFields, String uuid) async {

    final whereExpression = 'WHERE ecm:uuid = $documentUUID';

    final entries = await SpAthentoServices.findDocuments(configProvider, docType, selectFields, whereExpression);

    // Validar si Athento devolvió como mucho un sólo un documento
    if(entries.length > 1){
      throw Exception('Athento should have returned at most 1 document, instead of ${entries.length}.');
    }
    var foo = entries[0];
    // Validar si Athento devolvió uno un sólo un documento
    if(entries.length != 1){
      throw Exception('Document with UUID="$documentUUID" not found in Athento.');
    }

    return entries[0];
  }

  static Future<List<dynamic>> findDocuments(ConfigProvider configProvider, String docType,
      List<String> selectFields, String whereExpression) async {
    //TODO: revisar el resultado de Athento y arrojar un error en caso de que el response incluya un error en el JSON body.
    //TODO: estaría bueno limpiar los nombres feos de los metadatos por los nombres amigables, y poner un parámetro al final para indicar si se desean los nombres feos o no.

    if(!whereExpression.startsWith('WHERE')){
      var whereStartWord = _getFirstWord(whereExpression);
      throw Exception('the "whereExpresion" argument must start with "WHERE" instead of "".');
    }

    final renamedFieldValues = configProvider.getSelectFields(selectFields);
    final query = "SELECT ${renamedFieldValues.join(', ')} FROM $docType $whereExpression";
    final jsonRequestBody = {
      'params' :  {
        'pageSize': 20,
        'page': 0,
        'query': query
      }
    };

    final headers = configProvider.getHttpHeaders();

    //print("headers: " + JSON.stringify(headers));
    //print("request body: " + JSON.stringify(jsonRequestBody));

    final response = await SpWS.post(
        configProvider.getEndpointUrl(AthentoEndpoint.getDocument),
        headers:headers,
        parameters: {},
        body: jsonRequestBody);

    //console.log("response.status: " + response.statusCode);
    //console.log("response body: " + responseBody);

    final jsonBody = configProvider.parseResponse(response.body);

    final results = FindResults.fromJSON(jsonBody);
    // Validar si el response no trajo errores
    // TODO: parsear mejor el error de Athento
    if(results.hasError){
      throw Exception('An error occurred finding documents in Athento: ${results.errorMessage}');
    }
    //TODO: manejar paginación?? O hacerlo fuera mejor....

    //TODO: reemplazar los nombres feos de metadatos por otros más agradables.
    // Devolver sólo el JSON del documento
    final renamedEntries = results.entries.map((e) =>  configProvider.renameResultItemFields(e)).toList();
    return renamedEntries;
  }
}

class FindResults{
  bool isNextPageAvailable;
  bool hasError;
  int pageSize;
  String errorMessage;
  int resultsCount;
  List<dynamic>  entries;
  bool isLastPageAvailable;
  int currentPageIndex;
  int numberOfPages;
  String entityType; //entity-type
  bool isPreviousPageAvailable;
  int currentPageSize;
  bool isSortable;
  bool isPaginable;
  int maxPageSize;

  FindResults.fromJSON(Map<String, dynamic> json){
    isNextPageAvailable = json['isNextPageAvailable'];
    hasError = json['hasError'];
    pageSize = json['pageSize'];
    errorMessage = json['errorMessage'];
    resultsCount = json['resultsCount'];
    entries = json['entries'];
    isLastPageAvailable = json['isLastPageAvailable'];
    currentPageIndex = json['currentPageIndex'];
    numberOfPages = json['numberOfPages'];
    entityType = json['entityType'];
    isPreviousPageAvailable = json['isPreviousPageAvailable'];
    currentPageSize = json['currentPageSize'];
    isSortable = json['isSortable'];
    isPaginable = json['isPaginable'];
    maxPageSize = json['maxPageSize'];
  }
}

class TokenInfo{
  String token;
  String refreshToken;
  TokenInfo(this.token, this.refreshToken);

  TokenInfo.fromJSON(Map<String, dynamic>json): this(json['access_token'], json['refresh_token']);

  TokenInfo.fromJSONString(String jsonString): this.fromJSON(jsonDecode(jsonString));

  Map<String, dynamic> toJSON() {
    return {
      'access_token': token,
      'refresh_token': refreshToken
    };
  }

  String toJSONString() {
    return jsonEncode(toJSON());
  }
}


class UserInfo {
  String uuid;
  String idNumber;
  String userName;
  String firstName;
  String lastName;
  String email;
  String athentoSpaceUUID;

  UserInfo({@required this.uuid, @required this.idNumber,
    @required this.userName, @required this.firstName,
    @required this.lastName, @required this.email,
    @required this.athentoSpaceUUID});

  UserInfo.fromJSON(Map<String, dynamic>json) {
    uuid = json['uuid'];
    idNumber = json['identification_number'];
    userName = json['username'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    //athentoSpaceUUID = json['default_serie???']; //TODO: completar esto
  }

  UserInfo.fromJSONString(String jsonString) : this.fromJSON(jsonDecode(jsonString));

  String toJSONString() {

    return jsonEncode(toJSON());
  }

  Map<String, dynamic> toJSON() {
    return {
      UserInfoAthentoFieldName.uuid: uuid,
      UserInfoAthentoFieldName.idNumber: idNumber,
      UserInfoAthentoFieldName.userName: userName,
      UserInfoAthentoFieldName.firstName: firstName,
      UserInfoAthentoFieldName.lastName: lastName,
      UserInfoAthentoFieldName.email: email,
    };
  }
}

class UserInfoAthentoFieldName{
  static const String uuid = 'uuid';
  static const String idNumber = 'identification_number';
  static const String userName = 'username';
  static const String firstName = 'first_name';
  static const String lastName = 'last_name';
  static const String email = 'email';
}