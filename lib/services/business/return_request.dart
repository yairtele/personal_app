import 'package:flutter/foundation.dart';
import 'package:navigation_app/services/athento/athento_field_name.dart';

class ReturnRequest{
  String uuid;
  String title;
  String requestNumber;
  String batchNumber;
  String EAN;
  String commercialCode;
  String description;
  String retailReference;
  bool isAuditable;
  int quantity;
  //Map<String, XFile> photos;

  ReturnRequest({
    this.uuid,
    @required this.title,
    this.requestNumber,
    @required this.batchNumber,
    @required this.EAN,
    @required this.commercialCode,
    @required this.description,
    @required this.retailReference,
    @required this.isAuditable,
    @required this.quantity,
    //@required this.photos
  });

  Map<String, dynamic> toJSON() {
    return {
      AthentoFieldName.uuid: uuid,
      AthentoFieldName.title: title,
      ReturnRequestAthentoFieldName.requestNumber: requestNumber,
      ReturnRequestAthentoFieldName.batchNumber: batchNumber,
      ReturnRequestAthentoFieldName.EAN: EAN,
      ReturnRequestAthentoFieldName.commercialCode: commercialCode,
      ReturnRequestAthentoFieldName.retailReference: retailReference,
      ReturnRequestAthentoFieldName.description: description,
      ReturnRequestAthentoFieldName.isAuditable: isAuditable,
      ReturnRequestAthentoFieldName.quantity: quantity,
    };
  }

  ReturnRequest.fromJSON(Map<String, dynamic> json){
    uuid = json[AthentoFieldName.uuid];
    title = json[AthentoFieldName.title];
    requestNumber = json[ReturnRequestAthentoFieldName.requestNumber];
    batchNumber = json[ReturnRequestAthentoFieldName.batchNumber];
    EAN = json[ReturnRequestAthentoFieldName.EAN];
    commercialCode = json[ReturnRequestAthentoFieldName.commercialCode];
    retailReference = json[ReturnRequestAthentoFieldName.retailReference];
    description = json[ReturnRequestAthentoFieldName.description];
    isAuditable = json[ReturnRequestAthentoFieldName.isAuditable] == 'true';
    quantity =  json[ReturnRequestAthentoFieldName.quantity] == null ? null : int.tryParse(json[ReturnRequestAthentoFieldName.quantity]);
  }
}

class ReturnRequestAthentoFieldName{
  static const String uuid = AthentoFieldName.uuid;
  static const String title = AthentoFieldName.title;
  static const String requestNumber = 'ndeg_solicitud'; //TODO: cambiar el nombre del campo
  static const String batchNumber = 'ndeg_lote'; //TODO: cambiar el nombre del campo
  static const String EAN = 'ean';
  static const String commercialCode = 'codigo_comercial';
  static const String description = 'descripcion_producto';
  static const String retailReference = 'referencia_interna_solicitud';
  static const String isAuditable = 'es_auditable';
  static const String quantity = 'cantidad';
}
