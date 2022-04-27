import 'package:flutter/foundation.dart';
import 'package:navigation_app/services/business/return_photo.dart';


class NewReturn {
  String EAN;
  String sku;
  String commercialCode;
  String description;
  String retailReference;
  String brand;
  bool isAuditable;
  DateTime? lastSell;
  String? price;
  String legalEntity;
  String businessUnit;
  int? quantity;
  String? observations;
  String? customer_account;
  Map<String, ReturnPhoto> photos;

  NewReturn({
    required this.EAN,
    required this.sku,
    required this.commercialCode,
    required this.description,
    required this.retailReference,
    required this.brand,
    required this.isAuditable,
    required this.lastSell,
    required this.price,
    required this.legalEntity,
    required this.businessUnit,
    required this.quantity,
    required this.observations,
    required this.customer_account,
    required this.photos
  });
}