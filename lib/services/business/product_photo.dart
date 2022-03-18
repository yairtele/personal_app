import 'package:flutter/cupertino.dart';
import 'package:navigation_app/services/athento/athento_field_name.dart';

class ProductPhoto {
  String label;
  String uuid;
  String title;

  ProductPhoto({
    @required this.label,
    @required this.uuid,
    @required this.title
  });

  ProductPhoto.fromJSON(Map<String, dynamic> json){
    uuid = json[AthentoFieldName.uuid];
    title = json[AthentoFieldName.title];
    label = json[ProductPhotoAthentoFieldName.photoType];
  }

}

class ProductPhotoAthentoFieldName {
  static const String uuid = AthentoFieldName.uuid;
  static const String title = AthentoFieldName.title;
  static const String photoType = 'tipo_de_foto';
}