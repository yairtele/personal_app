class BusinessException implements Exception{
  String message;

  BusinessException([String this.message = 'Invalid login']);

  @override
  String toString() {
    return message;
  }
}