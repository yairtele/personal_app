import 'dart:collection';

import 'package:flutter/cupertino.dart';

class ProductInfo {
  String EAN;
  String commercialCode;
  String description;
  String retailAccount;
  DateTime lastSell;
  double lastSellPrice;
  UnmodifiableListView<String> _photos;
  bool _isAuditable;

  ProductInfo({
    @required this.EAN,
    @required this.commercialCode,
    @required this.description,
    @required this.retailAccount,
    @required this.lastSell,
    @required this.lastSellPrice,
    @required List<String> photos}){
    _photos = UnmodifiableListView(photos);
    _isAuditable = (photos != null && photos.length > 0);
  }

  UnmodifiableListView<String> get photos => _photos;
  bool get isAuditable => _isAuditable;
}
