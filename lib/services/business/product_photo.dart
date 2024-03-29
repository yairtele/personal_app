import 'package:flutter/cupertino.dart';
import 'package:marieyayo/services/athento/athento_field_name.dart';

class ProductPhoto {
  String uuid;
  String state;
  String label;
  String title;
  bool isDummy;

  ProductPhoto({
    required this.uuid,
    required this.state,
    required this.label,
    required this.title,
    required this.isDummy
  });

  ProductPhoto.fromJSON(Map<String, dynamic> json):
    uuid = json[ProductPhotoAthentoFieldName.uuid],
    state = json[ProductPhotoAthentoFieldName.state],
    title = json[ProductPhotoAthentoFieldName.title],
    label = json[ProductPhotoAthentoFieldName.photoType],
    isDummy = json[ProductPhotoAthentoFieldName.isDummy] == 'true';
}

class ProductPhotoAthentoFieldName {
  static const String uuid = AthentoFieldName.uuid;
  static const String title = AthentoFieldName.title;
  static const String state = AthentoFieldName.state;
  static const String photoType = 'tipo_de_foto';
  static const String isDummy = 'es_dummy';

}