class UserServices{
  static void login(String user, String password){
    if(!(user == 'juan' && password == 'pass')){
      throw InvalidLoginException('Usuario o clave inválidos.');
    }
  }
}

class InvalidLoginException implements Exception{
  String message;

  InvalidLoginException([String this.message = 'Invalid value']);

  @override
  String toString() {
    return message;
  }
}


