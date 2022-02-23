import 'package:flutter/cupertino.dart';
import 'package:navigation_app/services/athento/athento_field_name.dart';

class Product {
  String uuid;
  String title;
  String EAN;
  String commercialCode;
  String retailReference;
  String requestNumber;
  String description;

  // TODO: hacer requeridos los parámetros necesarios
  Product({
    this.uuid,
    @required this.title,
    @required this.EAN,
    @required this.commercialCode,
    @required this.retailReference,
    @required this.requestNumber,
    @required this.description,
  });
  Map<String, dynamic> toJSON() {
    return {
      AthentoFieldName.uuid: uuid,
      AthentoFieldName.title: title,
      ProductAthentoFieldName.requestNumber: requestNumber,
      ProductAthentoFieldName.EAN: EAN,
      ProductAthentoFieldName.commercialCode: commercialCode,
      ProductAthentoFieldName.retailReference: retailReference,
      ProductAthentoFieldName.description: description,
    };
  }

  Product.fromJSON(Map<String, dynamic> json){
    uuid = json[AthentoFieldName.uuid];
    title = json[AthentoFieldName.title];
    EAN = json[ProductAthentoFieldName.EAN];
    commercialCode = json[ProductAthentoFieldName.commercialCode];
    retailReference = json[ProductAthentoFieldName.retailReference];
    description = json[ProductAthentoFieldName.description];
    requestNumber = json[ProductAthentoFieldName.requestNumber];
  }
}

class ProductAthentoFieldName{
  static const String uuid = AthentoFieldName.uuid;
  static const String title = AthentoFieldName.title;
  static const String EAN = 'ean';
  static const String commercialCode = 'cod_articulo_retail';
  static const String retailReference = 'id_retail';
  static const String description = 'descripcion_producto';
  static const String requestNumber = 'ndeg_solicitud';
}

