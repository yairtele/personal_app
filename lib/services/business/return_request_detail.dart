import 'package:marieyayo/services/business/photo_detail.dart';
import 'package:marieyayo/services/business/product.dart';
import 'package:marieyayo/utils/ui/thumb_photo.dart';

class ReturnRequestDetail {
  List<Product> products;
  Map<String, ThumbPhoto> optionalPhotos;

  ReturnRequestDetail({
    required this.products,
    required this.optionalPhotos
  });

}