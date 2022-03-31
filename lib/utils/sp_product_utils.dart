import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/services/business/product_info.dart';

class SpProductUtils{

  static Future<ProductInfo> getProductInfoByEAN(String eanCode) {
    return BusinessServices.getProductInfoByEAN(eanCode);
  }
}