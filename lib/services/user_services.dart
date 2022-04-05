import 'package:navigation_app/config/cache.dart';
import 'package:navigation_app/config/configuration.dart';
import 'package:navigation_app/exceptions/custom_exception.dart';
import 'package:navigation_app/services/athento/basic_auth_config_provider.dart';
import 'package:navigation_app/services/athento/sp_athento_services.dart';

class UserServices{
  static Future<void> login(String user, String password) async{
    // Clear the cached data
    await Cache.clearAll();

    // Perform Login
    final serviceBaseUrl = Configuration.athentoAPIBaseURL;
    final configProvider = BasicAuthConfigProvider(serviceBaseUrl, user, password);
    if(Configuration.authenticationType == 'bearer_token'){
      final tokenInfo = await SpAthentoServices.getAuthenticationToken(configProvider, user, password);
      await Cache.saveTokenInfo(tokenInfo);
    }
  }
}

class InvalidLoginException extends CustomException{
  InvalidLoginException(String message, {Exception? cause}): super(message, cause: cause);
}


