
import 'dart:convert';
import 'athento_endpoint.dart';

abstract class ConfigProvider {
  final _defaultEndpointConfig = <String, String>{
    AthentoEndpoint.createDocument: 'nuxeo/site/automation/Athento.DocumentCreate/',
    AthentoEndpoint.createDocumentWithContent: 'nuxeo/site/automation/Athento.DocumentCreate/',
    AthentoEndpoint.deleteDocument: 'nuxeo/site/automation/Athento.DocumentDelete/',
    AthentoEndpoint.getContentAsBytes: 'nuxeo/api/v1/id/{file_uuid}/@blob/file:content',
    AthentoEndpoint.getDocument: 'nuxeo/site/automation/Athento.DocumentResultSet/',
    AthentoEndpoint.updateDocument: 'nuxeo/site/automation/Athento.DocumentUpdate/',
    AthentoEndpoint.updateDocumentContent: 'Blob.Attach/',
    AthentoEndpoint.getAuthToken: 'o/token/',
    AthentoEndpoint.getUserInfo: 'users/api/user/{user_name}/',

  };

  String _serviceBaseUrl = '';

  String get serviceBaseUrl => _serviceBaseUrl;

  Map<String, String>? _fieldNameInferenceConfig;

  Map<String, String>? get fieldNameInferenceConfig {
    return _fieldNameInferenceConfig;
  }


  ConfigProvider(String serviceBaseUrl, [Map<String, String>? fieldNameInferenceConfig]) {
    _serviceBaseUrl = serviceBaseUrl + (serviceBaseUrl.endsWith('/') ? '' : '/');
    _fieldNameInferenceConfig = fieldNameInferenceConfig ;
  }

  Map<String, dynamic> parseResponse(String responseBody) {
    return jsonDecode(responseBody);
  }


  String getEndpointUrl(String key) {
    if(_defaultEndpointConfig[key] == null){
      throw Exception('No endpoint URL was found for key "$key"');
    }
    return _serviceBaseUrl +  _defaultEndpointConfig[key]!;
  }


  String getAuthorizationHeader();

  Map<String, String> getHttpHeaders([Map<String, String>? addOrOverrideHeaders]) {
    final basicHeaders = {
      'Accept': 'application/json+nxentity, */*',
      'Accept-Encoding': 'gzip, deflate',
      'Authorization': getAuthorizationHeader(),
      'Content-Type': 'application/json',
      'Cache-Control': 'no-cache',
      'cache-control': 'no-cache'
    };

    final  httpHeaders = Map<String, String>();

    httpHeaders.addAll(basicHeaders);

    if(addOrOverrideHeaders != null){
      httpHeaders.addAll(addOrOverrideHeaders);
    }

    return httpHeaders;
  }

  Map<String, dynamic> getFieldValues(
      [String? title, Map<String, dynamic>? fieldValues]) {
    //console.log("BasicAuthConfigProvider.getFieldValues - entry")

    //console.log("inside renameFieldNames()");
    //console.log("fieldValues: " + JSON.stringify(fieldValues));
    //console.log("fieldNameInferenceConfig: " + JSON.stringify(fieldNameInferenceConfig));

    final renamedFieldsAndValues = Map<String, dynamic>();

    if (fieldValues == null) {
      fieldValues = Map<String, dynamic>();
    }

    if (title != null) {
      renamedFieldsAndValues['dc:title'] = title;
    }

    if (fieldNameInferenceConfig != null) {
      final fieldMap = Map<String, Map<String, dynamic>>();
      //Search fieldNameInferenceConfig's placeholders in fieldValues and add matches with the corresponding field prefix in fieldMap.
      for (final prefixEntry in fieldNameInferenceConfig!.keys) {
        //print("Recorrer fieldNameInferenceConfig");
        if (prefixEntry != 'defaultPrefix') {
          for (final fieldName in fieldValues.keys) {
            if (fieldName.indexOf(prefixEntry, 0) == 0) {
              final renamedFieldValuePair = Map<String, dynamic>();
              final renamedFieldName = fieldName.replaceFirst(
                  prefixEntry, fieldNameInferenceConfig![prefixEntry]!);
              renamedFieldValuePair[renamedFieldName] = fieldValues[fieldName];
              //console.log("fieldName: " + fieldName);
              //console.log("renamedFieldValuePair: " + JSON.stringify(renamedFieldValuePair));
              fieldMap[fieldName] = renamedFieldValuePair;
            }
          }
        }
      }

      //Iterate through fieldValues, and for fields not previously renamed (i.e, not found in fieldMap), add them with the default field prefix (fieldNameInferenceConfig.defaultPrefix) in fieldMap
      final defaultPrefix = fieldNameInferenceConfig!['defaultPrefix'] ?? '';

      //console.log("500")

      for (final fieldName in fieldValues.keys) {
        if (!fieldMap.containsKey(fieldName)) {
          final renamedFieldValuePair = Map<String, dynamic>();
          final renamedFieldName = !(fieldName == 'dc:title' || fieldName == 'ecm:uuid') ? defaultPrefix +
              fieldName : fieldName;
          renamedFieldValuePair[renamedFieldName] = fieldValues[fieldName];

          fieldMap[fieldName] = renamedFieldValuePair;
        }
      }
      //console.log("600")

      //Complete the final Athento request renamed fieldValues object

      //console.log("fieldMap.size: " + fieldMap.size);
      fieldMap.forEach((key, value) {
        //console.log("Object.assign: " + typeof Object.assign);
        //console.log("key: " + JSON.stringify(key));
        //console.log("value: " + JSON.stringify(value));
        //console.log("map: " + JSON.stringify(map));
        renamedFieldsAndValues.addAll(value);
      });
      //console.log(renamedFieldsAndValues);
      //console.log("700");

    } else {
      renamedFieldsAndValues.addAll(fieldValues);
    }
    //console.log("BasicAuthConfigProvider.getFieldValues - exit")

    return renamedFieldsAndValues;
  }

  List<String> getSelectFields(List<String> fieldNames) {
    //console.log("configProvider.getSelectFields: fieldNames: " + JSON.stringify(fieldNames));
    //console.log("fieldNames instanceof Array: " + Array.isArray(fieldNames)  );
    //console.log("SpLibs.isUndefinedOrNull(fieldNames): " + SpLibs.isUndefinedOrNull(fieldNames));
    //console.log("SpLibs.isUndefinedOrNull(fieldNames) || !Array.isArray(fieldNames): " + SpLibs.isUndefinedOrNull(fieldNames) || !Array.isArray(fieldNames));

    //Convert fieldNames into an object to be able to call this.getFieldValues()
    final fieldNamesObject = Map<String, dynamic>();
    for (var i = 0; i < fieldNames.length; i++) {
      fieldNamesObject[fieldNames[i]] = '';
    }

    //console.log("configProvider.getSelectFields: fieldNamesObject: " + JSON.stringify(fieldNamesObject));
    final renamedFieldNamesObject = getFieldValues(null, fieldNamesObject);

    //console.log("configProvider.getSelectFields: renamedFieldNamesObject: " + JSON.stringify(renamedFieldNamesObject));

    //Convert renamedFieldNamesObject back in an array of fieldNames
    final renamedFieldNamesArray = List<String>.empty(growable: true);
    for (var fieldName in renamedFieldNamesObject.keys) {
      //Add "metadata." prefix only to custom metadata fields
      if (fieldName.indexOf('dc:') == -1 && fieldName.indexOf('ecm:') == -1) {
        fieldName = 'metadata.' + fieldName;
      }
      renamedFieldNamesArray.add(fieldName);
    }
    return renamedFieldNamesArray;
  }

  Map<String, dynamic> renameResultItemFields(Map<String, dynamic> item) {
    final renamedItem =  Map<String, dynamic>();
    item.forEach((fieldName, value) {

      MapEntry<String, String>? prefixInfo;

      if(_fieldNameInferenceConfig != null){
        final foundPrefixInfos = _fieldNameInferenceConfig!.entries.where(
                (fieldPrefixInfo) => fieldName.startsWith('metadata.${fieldPrefixInfo.value}')
        );
        if (foundPrefixInfos.length > 1){
          throw Exception('There are ${foundPrefixInfos.length} entries in the field name inference configuration that match the field "$fieldName" included in the result item. There should be either zero or one match');
        }
        prefixInfo = foundPrefixInfos.length == 1 ? foundPrefixInfos.first : null;
      }
      else {
        prefixInfo = null;
      }

      if (prefixInfo != null) {
        // Renamed
        renamedItem[fieldName.replaceFirst('metadata.${prefixInfo.value}', '')] = value;
      }
      else{
        //Not renamed
        renamedItem[fieldName] = value;
      }
    });
    return renamedItem;
  }
}