class ReturnRequest {
  String retailReference;
  int cantidad;
  //TODO: validar uno de this.retailReference o this.description no sean vacíos ni nulos
  ReturnRequest({this.retailReference, this.cantidad});

  Map<String, dynamic> toJSON() {
    return {
      ReturnAthentoFieldName.retailReference: retailReference,
      ReturnAthentoFieldName.cantidad: cantidad,
    };
  }

  ReturnRequest.fromJSON(Map<String, dynamic> json){
    retailReference = json[ReturnAthentoFieldName.retailReference];
    cantidad = json[ReturnAthentoFieldName.cantidad];
  }
}

class ReturnAthentoFieldName{
  static const String retailReference = 'referencia_interna_solicitud';
  static const String cantidad = 'cantidad_solicitud';

}