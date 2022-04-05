abstract class CustomException implements Exception{
  String message;
  Exception? cause;
  CustomException(this.message, {this.cause});

  @override
  String toString(){
    return message;
  }
}

