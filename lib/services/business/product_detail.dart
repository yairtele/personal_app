import 'package:navigation_app/services/athento/binary_file_info.dart';
import 'package:navigation_app/services/business/photo_detail.dart';
import 'package:navigation_app/utils/ui/thumb_photo.dart';
import 'product_info.dart';

class ProductDetail {
  ProductInfo productInfo;
  Map<String, ThumbPhoto> productPhotos;

  ProductDetail({
    required this.productInfo,
    required this.productPhotos
  });

}