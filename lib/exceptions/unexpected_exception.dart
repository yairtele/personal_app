import 'custom_exception.dart';

class UnexpectedException extends CustomException{

  UnexpectedException(String message, {Exception? cause}): super(message, cause: cause);
}