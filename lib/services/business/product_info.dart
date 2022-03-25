import 'dart:collection';
import 'package:navigation_app/services/business/business_services.dart';

class ProductInfo {
  String EAN;
  String commercialCode;
  String sku;
  String description;
  String brand;
  String legalEntity;
  String businessUnit;
  ProductSalesInfo? salesInfo;
  ProductAuditRules auditRules;
  final bool _isAuditable;

  ProductInfo({
    required this.EAN,
    required this.commercialCode,
    required this.sku,
    required this.description,
    required this.brand,
    required this.legalEntity,
    required this.businessUnit,
    required this.salesInfo,
    required this.auditRules,
  }): _isAuditable = auditRules.photos.length > 0;

  bool get isAuditable => _isAuditable;
}
