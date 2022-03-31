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
  late ProductAuditRules auditRules;
  late final bool _isAuditable;


  ProductInfo.create({
    required this.EAN,
    required this.commercialCode,
    required this.sku,
    required this.description,
    required this.brand,
    required this.legalEntity,
    required this.businessUnit,
    required this.salesInfo,
    required ProductAuditRules? auditRules,
  }){
    if (auditRules == null) {
      _isAuditable = false;
      this.auditRules = ProductAuditRules(photos: [PhotoAuditInfo(label: 'Otra', name: 'otra')], lastSaleMaxAge: const Duration(days: 365));
    } else {
      _isAuditable = auditRules.photos.length > 1;
    }

  }

  bool get isAuditable => _isAuditable;
}
