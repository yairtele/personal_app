class SpFileUtils{

  static String getFileExtension(String filePath) {
    var lastSlashIndex = filePath.lastIndexOf(RegExp(r'[/\\]'));

    lastSlashIndex = lastSlashIndex < 0 ? 0 : lastSlashIndex;

    final lastDotIndex = filePath.indexOf('.', lastSlashIndex);

    if(lastDotIndex < 0){
      throw Exception('The filePath "$filePath" contains no extension.');
    }

    final fileExtension = filePath.substring(lastDotIndex);

    return fileExtension;
  }
}