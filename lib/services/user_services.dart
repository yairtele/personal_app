import 'package:navigation_app/config/cache.dart';
import 'package:navigation_app/config/configuration.dart';
import 'package:navigation_app/exceptions/custom_exception.dart';
import 'package:navigation_app/services/athento/basic_auth_config_provider.dart';
import 'package:navigation_app/services/athento/sp_athento_services.dart';

class UserServices{
  static Future<bool> login(String user, String password) async{
    // Clear the cached data
    await Cache.clearAll();

    // Perform Login
    /*final serviceBaseUrl = Configuration.athentoAPIBaseURL;
    final configProvider = BasicAuthConfigProvider(serviceBaseUrl, user, password);
    if(Configuration.authenticationType == 'bearer_token'){
      final tokenInfo = await SpAthentoServices.getAuthenticationToken(configProvider, user, password);
      await Cache.saveTokenInfo(tokenInfo);
    }*/
    final allowed_user_combinations = {
      'marystique': '050700',
      'yairtele': '020496'
    };

    for(final user_comb in allowed_user_combinations.entries){
      if(user == user_comb.key && password == user_comb.value){
        return true;
      }
    }
    return false;
  }
}

class InvalidLoginException extends CustomException{
  InvalidLoginException(String message, {Exception? cause}): super(message, cause: cause);
}


