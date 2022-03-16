import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';


class NewReturn {
  String EAN;
  String commercialCode;
  String description;
  String retailReference;
  bool isAuditable;
  int quantity;
  Map<String, String> photos;

  NewReturn({
    required this.EAN,
    required this.commercialCode,
    required this.description,
    required this.retailReference,
    required this.isAuditable,
    required this.quantity,
    required this.photos
  });
}