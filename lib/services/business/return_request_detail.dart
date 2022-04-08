import 'package:navigation_app/services/business/photo_detail.dart';
import 'package:navigation_app/services/business/product.dart';

class ReturnRequestDetail {
  List<Product> products;
  Map<String,PhotoDetail> optionalPhoto;

  ReturnRequestDetail({
    required this.products,
    required this.optionalPhoto
  });

}