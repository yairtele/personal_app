
import 'package:flutter/cupertino.dart';

class Batch {
  String retailReference;
  String description;
  String cuitRetail;
  String retailCompanyName;

  //TODO: validar uno de this.retailReference o this.description no sean vacíos ni nulos
  Batch({this.retailReference, this.description, @required this.cuitRetail, @required this.retailCompanyName});

  Map<String, dynamic> toJSON() {
    return {
      BatchAthentoFieldName.retailReference: retailReference,
      BatchAthentoFieldName.description: description,
      BatchAthentoFieldName.cuitRetail: cuitRetail,
      BatchAthentoFieldName.retailCompanyName: retailCompanyName
    };
  }

  Batch.fromJSON(Map<String, dynamic> json){
    retailReference = json[BatchAthentoFieldName.retailReference];
    description = json[BatchAthentoFieldName.description];
    cuitRetail = json[BatchAthentoFieldName.cuitRetail];
    retailCompanyName = json[BatchAthentoFieldName.retailCompanyName];
  }
}

class BatchAthentoFieldName{
  static const String retailReference = 'referencia_interna_lote';
  static const String description = 'descripcion_lote';
  static const String cuitRetail = 'cuit_cliente';
  static const String retailCompanyName = 'razon_social';
}