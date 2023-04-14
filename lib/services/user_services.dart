import 'package:marieyayo/config/cache.dart';
import 'package:marieyayo/config/configuration.dart';
import 'package:marieyayo/exceptions/custom_exception.dart';
import 'package:marieyayo/services/athento/basic_auth_config_provider.dart';
import 'package:marieyayo/services/athento/sp_athento_services.dart';

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

      throw InvalidLoginException('Usuario o clave inválidos');
  }
}

class InvalidLoginException extends CustomException{
  InvalidLoginException(String message, {Exception? cause}): super(message, cause: cause);
}


