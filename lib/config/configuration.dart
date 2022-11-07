import 'dart:ui';
import 'package:flutter/material.dart';

class Configuration{
  static const String productsFileName = 'products_db.csv';
  static const String salesFileName = 'sales_db.csv';
  static const String rulesFileName = 'rules_db.csv';
  static const Color customerPrimaryColor = Color(0xFF99cfe0);
  static const Color customerSecondaryColor = Color(0xFFce5eb3);
  static const String photosURL = 'https://drive.google.com/drive/u/1/folders/1da75DOhostOiiYIBtXmR376TYQgJqa3j';

  static String getPerformancesURL(username, offset) {
    return 'https://www.smule.com/${username}/performances/json?offset=${offset}';//el offset cuenta de a 25
  }

  static String getInitialPerformancesURL(username){
    return getPerformancesURL(username, '0');
  }
}