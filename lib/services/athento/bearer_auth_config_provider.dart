import 'config_provider.dart';

class BearerAuthConfigProvider  extends ConfigProvider {
  final String _token;
  final String _referer;

  BearerAuthConfigProvider(String serviceBaseUrl, String token, String referer,
      [Map<String, String>? fieldNameInferenceConfig])
      : _token = token,
        _referer = referer,
        super(serviceBaseUrl, fieldNameInferenceConfig);

  @override
  String getAuthorizationHeader() {
    if (_token.startsWith('Bearer ')) {
      return _token;
    }
    else {
      return 'Bearer ' + _token;
    }
  }

  @override
  Map<String, String> getHttpHeaders([Map<String, String>? addOrOverrideHeaders]) {
    // Call parent getHttpHeaders()
    final httpHeaders = super.getHttpHeaders(addOrOverrideHeaders);

    // Add the referer
    httpHeaders['Referer'] = _referer;

    return httpHeaders;
  }

}