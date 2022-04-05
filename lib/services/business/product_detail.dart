import 'package:navigation_app/services/athento/binary_file_info.dart';
import 'package:navigation_app/services/business/photo_detail.dart';
import 'product_info.dart';

class ProductDetail {
  ProductInfo productInfo;
  Map<String, PhotoDetail> productPhotos;

  ProductDetail({
    required this.productInfo,
    required this.productPhotos
  });

}