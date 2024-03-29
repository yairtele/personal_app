import 'package:marieyayo/services/athento/athento_field_name.dart';

class ReturnRequest{
  String? uuid;
  String? state;
  String title;
  String? requestNumber;
  String? batchNumber;
  String EAN;
  String sku;
  String commercialCode;
  String? description;
  String? retailReference;
  String? brand;
  bool isAuditable;
  int? quantity;
  String? lastSell;
  String? price;
  String legalEntity;
  String businessUnit;
  String? observations;
  String? customer_account;

  //Map<String, XFile> photos;

  ReturnRequest({
    this.uuid,
    this.state,
    required this.title,
    this.requestNumber,
    required this.batchNumber,
    required this.EAN,
    required this.sku,
    required this.commercialCode,
    required this.description,
    required this.retailReference,
    required this.brand,
    required this.isAuditable,
    required this.quantity,
    required this.lastSell,
    required this.price,
    required this.legalEntity,
    required this.businessUnit,
    required this.observations,
    required this.customer_account
    //@required this.photos
  });

  Map<String, dynamic> toJSON() {
    return {
      AthentoFieldName.uuid: uuid,
      AthentoFieldName.state: state,
      AthentoFieldName.title: title,
      ReturnRequestAthentoFieldName.requestNumber: requestNumber,
      ReturnRequestAthentoFieldName.batchNumber: batchNumber,
      ReturnRequestAthentoFieldName.EAN: EAN,
      ReturnRequestAthentoFieldName.sku: sku,
      ReturnRequestAthentoFieldName.commercialCode: commercialCode,
      ReturnRequestAthentoFieldName.retailReference: retailReference,
      ReturnRequestAthentoFieldName.brand: brand,
      ReturnRequestAthentoFieldName.description: description,
      ReturnRequestAthentoFieldName.isAuditable: isAuditable,
      ReturnRequestAthentoFieldName.quantity: quantity,
      ReturnRequestAthentoFieldName.lastSell: lastSell,
      ReturnRequestAthentoFieldName.price: price,
      ReturnRequestAthentoFieldName.legalEntity: legalEntity,
      ReturnRequestAthentoFieldName.businessUnit: businessUnit,
      ReturnRequestAthentoFieldName.observations: observations,
      ReturnRequestAthentoFieldName.customer_account: customer_account
    };
  }

  ReturnRequest.fromJSON(Map<String, dynamic> json):
    uuid = json[AthentoFieldName.uuid],
    state = json[AthentoFieldName.state],
    title = json[AthentoFieldName.title],
    requestNumber = json[ReturnRequestAthentoFieldName.requestNumber],
    batchNumber = json[ReturnRequestAthentoFieldName.batchNumber],
    EAN = json[ReturnRequestAthentoFieldName.EAN],
    sku = json[ReturnRequestAthentoFieldName.sku],
    commercialCode = json[ReturnRequestAthentoFieldName.commercialCode],
    retailReference = json[ReturnRequestAthentoFieldName.retailReference],
    brand = json[ReturnRequestAthentoFieldName.brand],
    description = json[ReturnRequestAthentoFieldName.description],
    isAuditable = json[ReturnRequestAthentoFieldName.isAuditable] == 'true',
    quantity =  json[ReturnRequestAthentoFieldName.quantity] == null ? null : int.tryParse(json[ReturnRequestAthentoFieldName.quantity]),
    lastSell = json[ReturnRequestAthentoFieldName.lastSell],
    price = json[ReturnRequestAthentoFieldName.price],
    legalEntity = json[ReturnRequestAthentoFieldName.legalEntity],
    businessUnit = json[ReturnRequestAthentoFieldName.businessUnit],
    observations = json[ReturnRequestAthentoFieldName.observations],
    customer_account = json[ReturnRequestAthentoFieldName.customer_account];
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
  static const String brand = 'marca';
  static const String isAuditable = 'es_auditable';
  static const String quantity = 'cantidad';
  static const String lastSell = 'fecha_ultima_venta';
  static const String price = 'precio';
  static const String legalEntity = 'juridica';
  static const String observations = 'observaciones';
  static const String customer_account = 'no_cta_cliente';
}