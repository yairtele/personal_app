import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class BinaryFileInfo{
  String contentType;
  String fileExtension;
  Uint8List bytes;
  BinaryFileInfo({ required String this.contentType, required this.fileExtension, required this.bytes });
}