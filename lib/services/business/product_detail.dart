import 'package:flutter/cupertino.dart';
import 'package:navigation_app/services/athento/athento_field_name.dart';
import 'package:navigation_app/services/athento/binary_file_info.dart';
import 'product_info.dart';

class ProductDetail {
  ProductInfo productInfo;
  Map<String, BinaryFileInfo?> productPhotos;

  ProductDetail({
    required this.productInfo,
    required this.productPhotos
  });

}