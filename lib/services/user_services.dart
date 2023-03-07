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
    for(final user_comb in Configuration.usersJson.entries){
      if(user == user_comb.key && password == user_comb.value['password']){
        return true;
      }
    }
    return false;
  }
}

class InvalidLoginException extends CustomException{
  InvalidLoginException(String message, {Exception? cause}): super(message, cause: cause);
}


