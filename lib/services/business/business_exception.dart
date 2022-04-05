class BusinessException implements Exception{
  String message;

  BusinessException([String this.message = 'A business service layer error has occurred']);

  @override
  String toString() {
    return message;
  }
}