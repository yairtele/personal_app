import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http/http.dart';

class SpWS {
  static Future<http.Response> post(String uri,
      {Map<String, String> headers, Map<String, String> parameters,
        body, Encoding encoding}) async {
    return _request(uri, method: RequestMethod.post,
        headers: headers,
        parameters: parameters,
        body: body,
        encoding: encoding);
  }

  static Future<http.Response> get(String uri,
      {Map<String, String> headers, Map<String, String> parameters,
      }) async {
    return _request(uri, method: RequestMethod.get,
        headers: headers,
        parameters: parameters);
  }

  static Future<http.Response> _request(String uri,
      {RequestMethod method, Map<String, String> parameters,
        Map<String, String> headers, body, Encoding encoding}) async {
    try {
      //print("SpWS.put - entry");
      encoding = encoding ?? Encoding.getByName('UTF8');

      parameters = parameters ?? Map<String, String>();
      final fullUri = SpWS.addQueryString(uri, parameters: parameters);

      // print(fullUrl);


    if (body is Map<String, String> && headers.containsValue('application/x-www-form-urlencoded')){
      //Do nothing but prevent body to fall throwgh the 'else' statement
    }
    else if (body is Map<String, dynamic>) {
    //console.log("Consideré esto un PlainObject: " + body)
      body = jsonEncode(body);
    }


      //console.log("antes de http.post");
      //console.log("fullUrl: " + fullUrl);
      //console.log("headers: " + JSON.stringify(headers));
      //console.log("body: " + body);
      //console.log("timeout: " + timeout);

      Response response;
      switch (method) {
        case RequestMethod.post:
          response = await http.post(Uri.parse(fullUri), headers: headers,
              body: body,
              encoding: encoding);
          break;
        case RequestMethod.get:
          response = await http.get(Uri.parse(fullUri), headers: headers);
          break;
        default:
          throw Exception('Method "$method" not supported.');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      else {

        throw Exception('Error al postear el request a la uri "$uri". Status Code: ${response.statusCode}. Error message: ${response.reasonPhrase}');
      }
    }
    on Exception catch (e) {
      throw e;
    }
  }

  static String addQueryString(String uri, {Map<String, String> parameters}) {
    var fullUri = uri;

    if (parameters != null) {
      var sep = '?';
      for (final item in parameters.entries) {
        fullUri += sep + '${item.key}=${item.value}';
        sep = '&';
      }
    }
    return fullUri;
  }
}

enum RequestMethod{
  post,
  get,
}

extension RequestMethodExtension on RequestMethod{
  String get value {
    String value;
    switch(this){
      case RequestMethod.post:
        value = 'POST';
        break;
      case RequestMethod.get:
        value = 'GET';
        break;
      default:
        value = '<WHAT?>'; // Nunca debería dar este valor
    }

    return value;
  }
}