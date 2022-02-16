
import 'package:flutter/cupertino.dart';

class Batch {
  String retailReference;
  String description;
  String cuitRetail;
  String retailCompanyName;
  String observation;
  //TODO: validar uno de this.retailReference o this.description no sean vacíos ni nulos
  Batch({this.retailReference, this.description, @required this.cuitRetail, @required this.retailCompanyName,this.observation});

  Map<String, dynamic> toJSON() {
    return {
      BatchAthentoFieldName.retailReference: retailReference,
      BatchAthentoFieldName.description: description,
      BatchAthentoFieldName.cuitRetail: cuitRetail,
      BatchAthentoFieldName.retailCompanyName: retailCompanyName,
      BatchAthentoFieldName.observation: observation
    };
  }

  Batch.fromJSON(Map<String, dynamic> json){
    retailReference = json[BatchAthentoFieldName.retailReference];
    description = json[BatchAthentoFieldName.description];
    cuitRetail = json[BatchAthentoFieldName.cuitRetail];
    retailCompanyName = json[BatchAthentoFieldName.retailCompanyName];
    observation = json[BatchAthentoFieldName.observation];
  }
}

class BatchAthentoFieldName{
  static const String retailReference = 'referencia_interna_lote';
  static const String description = 'descripcion_lote';
  static const String cuitRetail = 'cuit_cliente';
  static const String retailCompanyName = 'razon_social';
  static const String observation = 'observacion';
}