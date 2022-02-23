import 'dart:collection';

import 'package:flutter/cupertino.dart';

class ProductInfo {
  String EAN;
  String commercialCode;
  String description;
  UnmodifiableListView<String> _photos;
  DateTime lastSell;
  bool _isAuditable;

  ProductInfo({
    @required this.EAN,
    @required this.commercialCode,
    @required this.description,
    @required this.lastSell,
    @required List<String> photos}){
    _photos = UnmodifiableListView(photos);
    _isAuditable = (photos != null && photos.length > 0);
  }

  UnmodifiableListView<String> get photos => _photos;
  bool get isAuditable => _isAuditable;
}
