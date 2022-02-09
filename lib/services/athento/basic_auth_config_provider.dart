import 'dart:convert';
import 'config_provider.dart';

class BasicAuthConfigProvider extends ConfigProvider{
  final String _user;
  final String _password;

  BasicAuthConfigProvider(String serviceBaseUrl, String user, String password, [Map<String, String> fieldNameInferenceConfig]):
        _user = user, _password = password, super(serviceBaseUrl, fieldNameInferenceConfig);

  @override
  String getAuthorizationHeader() {
    return 'Basic ' + base64Encode(utf8.encode(_user + ':' + _password));
  }
}

