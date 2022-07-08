import 'dart:ui';
import 'package:flutter/material.dart';

class Configuration{
  static String get athentoAPIBaseURL => 'https://newsan.athento.com';
  static String get athentoUser => 'app.mobile.integration';
  static String get athentoPassword => 'lakf73%@_klh&^hklfJHGDL;=JHD';
  static String get athentoClientId => 'kcGEi6OzIc1W32F5N3pSXQFfDzMeqIzpdSejNVEs';
  static String get athentoClientSecret => 'rqt0XE901BXoa0PetXTn2dKaEJvDYLBODofA0cbuvf3sw3iSeHpP9F2MPmvl8MZ9ERxJZHj7MI2mOO3LGiquuHu871wb1ca2dWu2OB7fiXk0Dxn6bVUTVN4kcMNrhcev';
  static String get authenticationType => 'bearer_token'; // 'bearer_token' | 'basic'
  static Color get customerPrimaryColor => const Color(0xFF741526);
  static MaterialColor get customerSecondaryColor => Colors.grey;
  static const String productsFileName = 'products_db.csv';
  static const String salesFileName = 'sales_db.csv';
  static const String rulesFileName = 'rules_db.csv';
}