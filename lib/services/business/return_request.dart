import 'package:navigation_app/services/athento/athento_field_name.dart';

class ReturnRequest{
  String? uuid;
  String title;
  String? requestNumber;
  String? batchNumber;
  String EAN;
  String sku;
  String commercialCode;
  String? description;
  String? retailReference;
  bool isAuditable;
  int? quantity;
  String? lastSell;
  String? price;
  String legalEntity;
  String businessUnit;
  //Map<String, XFile> photos;

  ReturnRequest({
    this.uuid,
    required this.title,
    this.requestNumber,
    required this.batchNumber,
    required this.EAN,
    required this.sku,
    required this.commercialCode,
    required this.description,
    required this.retailReference,
    required this.isAuditable,
    required this.quantity,
    required this.lastSell,
    required this.price,
    required this.legalEntity,
    required this.businessUnit
    //@required this.photos
  });

  Map<String, dynamic> toJSON() {
    return {
      AthentoFieldName.uuid: uuid,
      AthentoFieldName.title: title,
      ReturnRequestAthentoFieldName.requestNumber: requestNumber,
      ReturnRequestAthentoFieldName.batchNumber: batchNumber,
      ReturnRequestAthentoFieldName.EAN: EAN,
      ReturnRequestAthentoFieldName.sku: sku,
      ReturnRequestAthentoFieldName.commercialCode: commercialCode,
      ReturnRequestAthentoFieldName.retailReference: retailReference,
      ReturnRequestAthentoFieldName.description: description,
      ReturnRequestAthentoFieldName.isAuditable: isAuditable,
      ReturnRequestAthentoFieldName.quantity: quantity,
      ReturnRequestAthentoFieldName.lastSell: lastSell,
      ReturnRequestAthentoFieldName.price: price,
      ReturnRequestAthentoFieldName.legalEntity: legalEntity,
      ReturnRequestAthentoFieldName.businessUnit: businessUnit
    };
  }

  ReturnRequest.fromJSON(Map<String, dynamic> json):
    uuid = json[AthentoFieldName.uuid],
    title = json[AthentoFieldName.title],
    requestNumber = json[ReturnRequestAthentoFieldName.requestNumber],
    batchNumber = json[ReturnRequestAthentoFieldName.batchNumber],
    EAN = json[ReturnRequestAthentoFieldName.EAN],
    sku = json[ReturnRequestAthentoFieldName.sku],
    commercialCode = json[ReturnRequestAthentoFieldName.commercialCode],
    retailReference = json[ReturnRequestAthentoFieldName.retailReference],
    description = json[ReturnRequestAthentoFieldName.description],
    isAuditable = json[ReturnRequestAthentoFieldName.isAuditable] == 'true',
    quantity =  json[ReturnRequestAthentoFieldName.quantity] == null ? null : int.tryParse(json[ReturnRequestAthentoFieldName.quantity]),
    lastSell = json[ReturnRequestAthentoFieldName.lastSell] == null ? null : json[ReturnRequestAthentoFieldName.lastSell],
    price = json[ReturnRequestAthentoFieldName.price],
    legalEntity = json[ReturnRequestAthentoFieldName.legalEntity],
    businessUnit = json[ReturnRequestAthentoFieldName.businessUnit];
}

class ReturnRequestAthentoFieldName{
  static const String uuid = AthentoFieldName.uuid;
  static const String title = AthentoFieldName.title;
  static const String requestNumber = 'ndeg_solicitud'; //TODO: cambiar el nombre del campo
  static const String batchNumber = 'ndeg_lote'; //TODO: cambiar el nombre del campo
  static const String EAN = 'ean';
  static const String sku = 'sku';
  static const String businessUnit = 'linea_de_negocio';
  static const String commercialCode = 'codigo_comercial';
  static const String description = 'descripcion_producto';
  static const String retailReference = 'referencia_interna_solicitud';
  static const String isAuditable = 'es_auditable';
  static const String quantity = 'cantidad';
  static const String lastSell = 'fecha_ultima_venta';
  static const String price = 'precio';
  static const String legalEntity = 'juridica';
}