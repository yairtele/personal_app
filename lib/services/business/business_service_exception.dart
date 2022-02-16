class BusinessServiceException implements Exception{
  String message;

  BusinessServiceException([String this.message = 'Invalid login']);

  @override
  String toString() {
    return message;
  }
}