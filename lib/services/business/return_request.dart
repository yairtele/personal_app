class ReturnRequest {
  String retailReference;
  int cantidad;
  String descripcion;
  //TODO: validar uno de this.retailReference o this.description no sean vacíos ni nulos
  ReturnRequest({this.retailReference, this.cantidad,this.descripcion});

  Map<String, dynamic> toJSON() {
    return {
      ReturnAthentoFieldName.retailReference: retailReference,
      ReturnAthentoFieldName.cantidad: cantidad,
      ReturnAthentoFieldName.descripcion: descripcion,
    };
  }

  ReturnRequest.fromJSON(Map<String, dynamic> json){
    retailReference = json[ReturnAthentoFieldName.retailReference];
    cantidad = json[ReturnAthentoFieldName.cantidad];
    descripcion = json[ReturnAthentoFieldName.descripcion];
  }
}

class ReturnAthentoFieldName{
  static const String retailReference = 'referencia_interna_solicitud';
  static const String cantidad = 'cantidad_solicitud';
  static const String descripcion = 'descripcion_solicitud';
}