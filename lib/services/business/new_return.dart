import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';


class NewReturn {
  String EAN;
  String sku;
  String commercialCode;
  String description;
  String retailReference;
  String brand;
  bool isAuditable;
  String? lastSell;
  String? price;
  String legalEntity;
  String businessUnit;
  int? quantity;
  Map<String, String> photos;

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
    required this.photos
  });
}