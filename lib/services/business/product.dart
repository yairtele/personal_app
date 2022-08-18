import 'package:flutter/cupertino.dart';
import 'package:navigation_app/services/athento/athento_field_name.dart';
import 'package:navigation_app/services/business/return_request.dart';

class Product {
  String? uuid;
  String? state;
  String title;
  String EAN;
  String commercialCode;
  String? observations;
  String? retailReference; //TODO: está bien que pueda ser nulo? Debería ser string vacío en todo caso?
  String? requestNumber; //TODO: ver cómo asegurarnos que este dato nunca sea nulo. O ver si se elimina.
                          // Lo mismo para los demás autonuméricos en cada formulario de Athento
  String description;

  Product({
    this.uuid,
    this.state,
    required this.title,
    required this.EAN,
    required this.commercialCode,
    required this.retailReference,
    required this.requestNumber,
    required this.description,
    required this.observations
  });
  Map<String, dynamic> toJSON() {
    return {
      AthentoFieldName.uuid: uuid,
      AthentoFieldName.state: state,
      AthentoFieldName.title: title,
      ProductAthentoFieldName.requestNumber: requestNumber,
      ProductAthentoFieldName.EAN: EAN,
      ProductAthentoFieldName.commercialCode: commercialCode,
      ProductAthentoFieldName.retailReference: retailReference,
      ProductAthentoFieldName.description: description,
      ProductAthentoFieldName.observations: observations
    };
  }

  Product.fromJSON(Map<String, dynamic> json):
    uuid = json[AthentoFieldName.uuid],
    state = json[AthentoFieldName.state],
    title = json[AthentoFieldName.title],
    EAN = json[ProductAthentoFieldName.EAN],
    commercialCode = json[ProductAthentoFieldName.commercialCode],
    retailReference = json[ProductAthentoFieldName.retailReference],
    description = json[ProductAthentoFieldName.description],
    requestNumber = json[ProductAthentoFieldName.requestNumber],
    observations = json[ProductAthentoFieldName.observations];
}

class ProductAthentoFieldName{
  static const String uuid = AthentoFieldName.uuid;
  static const String title = AthentoFieldName.title;
  static const String EAN = 'ean';
  static const String commercialCode = 'cod_articulo_retail';
  static const String retailReference = 'id_retail';
  static const String description = 'descripcion_producto';
  static const String requestNumber = 'ndeg_solicitud';
  static const String observations = 'observaciones';
}

