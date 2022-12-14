import 'dart:convert';
import 'package:http/http.dart';
import 'package:navigation_app/config/configuration.dart';
import 'package:navigation_app/services/athento/athento_endpoint.dart';
import 'package:navigation_app/services/athento/basic_auth_config_provider.dart';
import 'package:navigation_app/services/athento/athento_field_name.dart';
import 'package:navigation_app/services/sp_ws/multipart_message_builder.dart';
import 'package:navigation_app/services/sp_ws/sp_ws.dart';
import 'package:navigation_app/services/sp_ws/web_service_exception.dart';
import 'package:navigation_app/services/user_services.dart';
import 'binary_file_info.dart';
import 'config_provider.dart';

class SpAthentoServices {
  static Future<UserInfo> getUserInfo(ConfigProvider configProvider,
      String user_name_or_uuid) async {
    final uri = configProvider.getEndpointUrl(AthentoEndpoint.getUserInfo)
        .replaceFirst('{user_name}', user_name_or_uuid);
    final headers = configProvider.getHttpHeaders();

    final response = await SpWS.get(uri, headers: headers, parameters: {});

    final userInfo = UserInfo.fromJSON(_jsonDecodeResponseUTF8(response));
    if (userInfo.idNumber == '') {
      throw Exception(
          'El usuario $user_name_or_uuid no tiene el CUIT de retailer cargado en su perfil de Athento');
    }

    return userInfo;
  }

  static Map<String, dynamic> _jsonDecodeResponseUTF8(Response response){
    return jsonDecode(const Utf8Decoder().convert(response.bodyBytes));
  }
  /*static Future<TokenInfo> getAuthenticationToken(
      BasicAuthConfigProvider configProvider, String userName,
      String password) async {
    try{
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

      final jsonResponse = _jsonDecodeResponseUTF8(response);
      return TokenInfo.fromJSON(jsonResponse);
    }
    on WebServiceException catch(e){
      if (e.response != null) {
        final response = e.response!;
        if(response.statusCode == 400){
          final jsonResponse = _jsonDecodeResponseUTF8(response);
          if(jsonResponse['error_description'] != null
              && jsonResponse['error_description'] == 'Invalid credentials given.'){
            throw InvalidLoginException('Usuario o clave inv??lidos', cause: e);
          }
        }
      }
      throw e;
    }
    on Exception catch (e){
      throw e;
    }
    on Error catch (e){
      throw e;
    }
  }*/

  static Future<Map<String, dynamic>> createDocument({
    required ConfigProvider configProvider,
    required String? containerUUID, required String docType, required String title,
    required Map<String,
        dynamic> fieldValues, String auditMessage = ''}) async {
    fieldValues.removeWhere((key, value) => key == AthentoFieldName.uuid);

    final renamedFieldValues = configProvider.getFieldValues(
        title, fieldValues);

    final jsonRequestBody = {
      if (containerUUID != null) 'input': containerUUID,
      'params': {
        'type': docType,
        'audit': auditMessage,
        'properties': renamedFieldValues,
      }
    };

    final headers = configProvider.getHttpHeaders();

    final response = await SpWS.post(
        configProvider.getEndpointUrl('createDocument'), parameters: {},
        headers: headers,
        body: jsonRequestBody);

    return configProvider.parseResponse(response);
  }


  static Future<Map<String, dynamic>> createDocumentWithContent({
    required ConfigProvider configProvider,
    required String containerUUID, required String docType, required String title,
    required Map<String, dynamic> fieldValues, required List<
        int> content, required String friendlyFileName, String auditMessage = ''}) async {
    if (content.length == 0) {
      throw Exception(
          '"content" cannot be neither null nor a zero length byte array');
    }

    final documentContentType = SpWS.getContentTypeFromFilePath(
        friendlyFileName);
    final contentAsBase64 = base64Encode(content);

    final renamedFieldValues = configProvider.getFieldValues(
        title, fieldValues);

    final jsonRequestBody = {
      'input': containerUUID,
      'params': {
        'type': docType,
        'audit': auditMessage,
        'properties': renamedFieldValues
      }
    };

    final mb = MultipartMessageBuilder();

    /// Define message parts ///
    // Document info part: Athento Document container uuid, docType, custom fields, etc
    final documentInfoPartHeaders = {
      'Content-Disposition': 'form-data; name="input"'
    };
    final documentInfoPartContent = jsonEncode(jsonRequestBody).replaceAll(
        '{', '{\n');

    // Document content part: file to be uploaded in base64 format.
    final documentContentPartHeaders = {
      //'Content-Disposition': 'form-data; name="Michelle"; filename="sample.pdf"'
      'Content-Disposition': 'form-data; name="$friendlyFileName", filename="$friendlyFileName"',
      'Content-Type': documentContentType,
      'Content-Transfer-Encoding': 'base64'
    };

    final documentContentPartContent = contentAsBase64;

    //Add parts to the message builder
    mb.addPart(documentInfoPartHeaders, documentInfoPartContent);
    mb.addPart(documentContentPartHeaders, documentContentPartContent);
    final messageBody = mb.build();

    //console.log("messageBody: " + messageBody);

    final messageHeaders = configProvider.getHttpHeaders({
      'Content-Type': 'multipart/form-data; boundary=' +
          mb.getBoundaryString()
    });

    final response = await SpWS.post(
        configProvider.getEndpointUrl('createDocumentWithContent'),
        parameters: null,
        headers: messageHeaders,
        body: messageBody);

    return configProvider.parseResponse(response);

  }

  static String _getFirstWord(String inputString) {
    final wordList = inputString.split('');
    return wordList.isNotEmpty ? wordList[0] : '';
  }


  static Future<Map<String, dynamic>> updateDocumentContent(
      { required ConfigProvider configProvider, required String documentUUID, required List<
          int> content, required String friendlyFileName, String auditMessage = ''}) async {

    final documentContentType = SpWS.getContentTypeFromFilePath(friendlyFileName);

    final contentAsBase64 = base64Encode(content);

    final jsonRequestBody = {
      'params': {
        'audit': auditMessage,
        'document': documentUUID
      }
    };

    final mb = MultipartMessageBuilder();

    /// Define message parts ///
    // Document info part: Athento Document container uuid, docType, custom fields, etc
    final documentInfoPartHeaders = {
      'Content-Disposition': 'form-data; name="input"'
    };

    final documentInfoPartContent = jsonEncode(jsonRequestBody);//.replaceAll('{', '{\n');

    // Document content part: file to be uploaded in base64 format.
    final documentContentPartHeaders = {
      'Content-Disposition': 'form-data; name="$friendlyFileName", filename="$friendlyFileName"',
      'Content-Type': documentContentType,
      'Content-Transfer-Encoding': 'base64'
    };

    final documentContentPartContent = contentAsBase64;

    //Add parts to the message builder
    mb.addPart(documentInfoPartHeaders, documentInfoPartContent);
    mb.addPart(documentContentPartHeaders, documentContentPartContent);
    final messageBody = mb.build();

    //console.log("messageBody: " + messageBody);
    final messageHeaders = configProvider.getHttpHeaders({
      'Content-Type': 'multipart/form-data; boundary=' + mb.getBoundaryString()
    });

    final response = await SpWS.post(
        configProvider.getEndpointUrl('updateDocumentContent'), parameters: {},
        headers: messageHeaders, body: messageBody);

    return configProvider.parseResponse(response);
}

  static Future<Map<String, dynamic>> getDocument(ConfigProvider configProvider,
      String docType,
      String documentUUID, List<String> selectFields) async {
    final whereExpression = 'WHERE ecm:uuid = $documentUUID';

    final entries = await SpAthentoServices.findDocuments(
        configProvider, docType, selectFields, whereExpression);

    // Validar si Athento devolvi?? como mucho un s??lo un documento
    if (entries.length > 1) {
      throw Exception(
          'Athento should have returned at most 1 document, instead of ${entries
              .length}.');
    }

    // Validar si Athento devolvi?? uno un s??lo un documento
    if (entries.length != 1) {
      throw Exception(
          'Document with UUID="$documentUUID" not found in Athento.');
    }

    return entries[0];
  }

  static Future<List<dynamic>> findDocuments(ConfigProvider configProvider,
      String docType,
      List<String> selectFields, String whereExpression) async {
    //TODO: revisar el resultado de Athento y arrojar un error en caso de que el response incluya un error en el JSON body.
    //TODO: estar??a bueno limpiar los nombres feos de los metadatos por los nombres amigables, y poner un par??metro al final para indicar si se desean los nombres feos o no.

    if (!whereExpression.startsWith('WHERE')) {
      final whereStartWord = _getFirstWord(whereExpression);
      throw Exception(
          'the "whereExpression" argument must start with "WHERE" instead of "$whereStartWord".');
    }
    //TODO: manejar paginaci??n
    final renamedFieldValues = configProvider.getSelectFields(selectFields);
    final query = "SELECT ${renamedFieldValues.join(
        ', ')} FROM $docType $whereExpression";
    final jsonRequestBody = {
      'params': {
        'pageSize': 10000,
        'page': 0,
        'query': query
      }
    };

    final headers = configProvider.getHttpHeaders();

    //print(headers);
    //print(jsonRequestBody);

    final response = await SpWS.post(
        configProvider.getEndpointUrl(AthentoEndpoint.getDocument),
        headers: headers,
        parameters: {},
        body: jsonRequestBody);

    //console.log("response.status: " + response.statusCode);
    //console.log("response body: " + responseBody);

    final jsonBody = configProvider.parseResponse(response);

    final results = FindResults.fromJSON(jsonBody);
    // Validar si el response no trajo errores
    // TODO: parsear mejor el error de Athento
    if (results.hasError) {
      throw Exception('An error occurred finding documents in Athento: ${results
          .errorMessage}');
    }
    //TODO: manejar paginaci??n?? O hacerlo fuera mejor....

    //TODO: reemplazar los nombres feos de metadatos por otros m??s agradables.
    // Devolver s??lo el JSON del documento
    final renamedEntries = results.entries.map((e) =>
        configProvider.renameResultItemFields(e)).toList();
    return renamedEntries;
  }


  static Future<Map<String, dynamic>> deleteDocument(
      {required ConfigProvider configProvider, required String documentUUID, String? auditMessage}) async {
    final jsonRequestBody = {
      'input': documentUUID,
      'params': {
        'audit': auditMessage,
      }
    };

    final headers = configProvider.getHttpHeaders();

    //console.log("endpoint: " + configProvider.getServiceUrl() + configProvider.getEndpointName("deleteDocument"));
    final response = await SpWS.post(
        configProvider.getEndpointUrl(AthentoEndpoint.deleteDocument),
        parameters: {}, headers: headers,
        body: jsonRequestBody);

    //console.log("response.status: " + response.statusCode);
    //console.log("response.body: " + response.body);

    return configProvider.parseResponse(response);


    //console.log(JSON.stringify(jsonRequestBody));
  }

  static Future<Map<String, dynamic>> updateDocument({ required ConfigProvider configProvider, required String documentUUID,
          String? title, required Map<String, dynamic> fieldValues, String? auditMessage}) async {

    final  renamedFieldValues = configProvider.getFieldValues(title, fieldValues);

    final jsonRequestBody = {
      'input': documentUUID,
      'params': {
      'audit': auditMessage,
        'properties': renamedFieldValues
      }
    };

    final headers = configProvider.getHttpHeaders();

    //console.log("endpoint: " + configProvider.getServiceUrl() + configProvider.getEndpointName("updateDocument"));
    final response = await SpWS.post(configProvider.getEndpointUrl(AthentoEndpoint.updateDocument), parameters:  {}, headers:  headers,
        body: jsonRequestBody);

    return configProvider.parseResponse(response);
  }


  static Future<BinaryFileInfo> getContentAsBytes ({ required ConfigProvider configProvider, required String documentUUID}) async {

    final headers = configProvider.getHttpHeaders();

    //Invocar a Athento para obtener el archivo
    final url = configProvider.getEndpointUrl('getContentAsBytes').replaceFirst('{file_uuid}', documentUUID);

    final response = await SpWS.get(url,parameters: {}, headers: headers);

    //Obtener el content type del archivo guardado en Athento.
    final contentType = response.headers['Content-Type'] ?? response.headers['content-type'] ;

    if (contentType == null){
      throw Exception('Could not determine content type of the binary file contained in document "$documentUUID".');
    }

    //Obtener la extensi??n de archivo
    final fileExtension = SpWS.getExtensionFromMimeType(contentType);

    return BinaryFileInfo(
      contentType: contentType,
      fileExtension: fileExtension,
      bytes: response.bodyBytes
    );
  }


}

class FindResults{
  bool isNextPageAvailable;
  bool hasError;
  int pageSize;
  String? errorMessage;
  int resultsCount;
  List<dynamic>  entries;
  bool isLastPageAvailable;
  int currentPageIndex;
  int numberOfPages;
  String? entityType; //entity-type
  bool isPreviousPageAvailable;
  int currentPageSize;
  bool isSortable;
  bool isPaginable;
  int maxPageSize;

  FindResults.fromJSON(Map<String, dynamic> json):
    isNextPageAvailable = json['isNextPageAvailable'],
    hasError = json['hasError'],
    pageSize = json['pageSize'],
    errorMessage = json['errorMessage'],
    resultsCount = json['resultsCount'],
    entries = json['entries'],
    isLastPageAvailable = json['isLastPageAvailable'],
    currentPageIndex = json['currentPageIndex'],
    numberOfPages = json['numberOfPages'],
    entityType = json['entityType'],
    isPreviousPageAvailable = json['isPreviousPageAvailable'],
    currentPageSize = json['currentPageSize'],
    isSortable = json['isSortable'],
    isPaginable = json['isPaginable'],
    maxPageSize = json['maxPageSize'];
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
  String idNumber;
  String userName;
  String firstName;
  String lastName;
  String email;
  //String athentoSpaceUUID;

  UserInfo({required this.idNumber,
    required this.userName, required this.firstName,
    required this.lastName, required this.email});

  UserInfo.fromJSON(Map<String, dynamic>json):
    idNumber = json['identification_number'],
    userName = json['username'],
    firstName = json['first_name'],
    lastName = json['last_name'],
    email = json['email'];
    //athentoSpaceUUID = json['default_serie???']; //TODO: completar esto


  UserInfo.fromJSONString(String jsonString) : this.fromJSON(jsonDecode(jsonString));

  String toJSONString() {

    return jsonEncode(toJSON());
  }

  Map<String, dynamic> toJSON() {
    return {
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


