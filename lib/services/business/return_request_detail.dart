import 'package:navigation_app/services/business/photo_detail.dart';
import 'package:navigation_app/services/business/product.dart';
import 'package:navigation_app/utils/ui/thumb_photo.dart';

class ReturnRequestDetail {
  List<Product> products;
  Map<String, ThumbPhoto> optionalPhotos;

  ReturnRequestDetail({
    required this.products,
    required this.optionalPhotos
  });

}