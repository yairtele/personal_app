import 'package:navigation_app/config/configuration.dart';
import 'package:navigation_app/services/athento/basic_auth_config_provider.dart';
import 'package:navigation_app/services/athento/sp_athento_services.dart';

class UserServices{
  static Future<TokenInfo> login(String user, String password) async{
    final serviceBaseUrl = Configuration.athentoAPIBaseURL;
    final configProvider = BasicAuthConfigProvider(serviceBaseUrl, user, password);
    final tokenInfo = await SpAthentoServices.getAuthenticationToken(configProvider, user, password);
    return tokenInfo;
  }
}

class InvalidLoginException implements Exception{
  String message;

  InvalidLoginException([String this.message = 'Invalid login']);

  @override
  String toString() {
    return message;
  }
}


