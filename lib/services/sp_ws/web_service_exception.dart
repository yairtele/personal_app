import 'package:http/http.dart';
import 'package:marieyayo/exceptions/custom_exception.dart';

class WebServiceException extends CustomException{
  Response? response;
  WebServiceException(String message, {required this.response, Exception? cause}): super(message, cause: cause);
}