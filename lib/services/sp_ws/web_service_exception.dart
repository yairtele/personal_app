import 'package:http/http.dart';
import 'package:navigation_app/exceptions/custom_exception.dart';

class WebServiceException extends CustomException{
  Response? response;
  WebServiceException(String message, {required this.response, Exception? cause}): super(message, cause: cause);
}