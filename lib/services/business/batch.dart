
import 'package:flutter/cupertino.dart';

import '../athento/athento_field_name.dart';

class Batch {
  String? uuid;
  String title;
  String? batchNumber; // Athento Auto-numbering ID
  String? retailReference;
  String? description;
  String cuitRetail;
  String retailCompanyName;
  String? observation;
  //TODO: validar uno de this.retailReference o this.description no sean vacíos ni nulos
  Batch({this.uuid, required this.title, this.batchNumber, required this.retailReference, this.description = '', required this.cuitRetail, required this.retailCompanyName, this.observation = ''});

  Map<String, dynamic> toJSON() {
    return {
      AthentoFieldName.uuid: uuid,
      AthentoFieldName.title: title,
      BatchAthentoFieldName.batchNumber: batchNumber,
      BatchAthentoFieldName.retailReference: retailReference,
      BatchAthentoFieldName.description: description,
      BatchAthentoFieldName.cuitRetail: cuitRetail,
      BatchAthentoFieldName.retailCompanyName: retailCompanyName,
      BatchAthentoFieldName.observation: observation
    };
  }

  Batch.fromJSON(Map<String, dynamic> json):
    uuid = json[AthentoFieldName.uuid],
    title = json[AthentoFieldName.title],
    batchNumber = json[BatchAthentoFieldName.batchNumber],
    retailReference = json[BatchAthentoFieldName.retailReference],
    description = json[BatchAthentoFieldName.description],
    cuitRetail = json[BatchAthentoFieldName.cuitRetail] ?? 'ERROR: debe tener CUIT', //TODO: sacar el condicional: no puede ser null el CUIT retail
    retailCompanyName = json[BatchAthentoFieldName.retailCompanyName] ?? 'ERROR: debe tener Razon social', //TODO: sacar el condicional: no puede ser null la razon social
    observation = json[BatchAthentoFieldName.observation];
}

class BatchAthentoFieldName{
  static const String uuid = 'ecm:uuid';
  static const String title = 'dc:title';
  static const String batchNumber = 'ndeg_lote';
  static const String retailReference = 'referencia_interna_lote';
  static const String description = 'descripcion_lote';
  static const String cuitRetail = 'cuit_cliente';
  static const String retailCompanyName = 'razon_social';
  static const String observation = 'observacion';
}