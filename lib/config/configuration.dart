import 'dart:ui';
import 'package:flutter/material.dart';

class Configuration{
  static const String athentoAPIBaseURL = 'https://newsan.athento.com';
  static const String athentoUser = 'app.mobile.integration';
  static const String athentoPassword = 'lakf73%@_klh&^hklfJHGDL;=JHD';
  static const String athentoClientId = 'kcGEi6OzIc1W32F5N3pSXQFfDzMeqIzpdSejNVEs';
  static const String athentoClientSecret = 'rqt0XE901BXoa0PetXTn2dKaEJvDYLBODofA0cbuvf3sw3iSeHpP9F2MPmvl8MZ9ERxJZHj7MI2mOO3LGiquuHu871wb1ca2dWu2OB7fiXk0Dxn6bVUTVN4kcMNrhcev';
  static const String authenticationType = 'bearer_token'; // 'bearer_token' | 'basic'
  static const String productsFileName = 'products_db.csv';
  static const String salesFileName = 'sales_db.csv';
  static const String rulesFileName = 'rules_db.csv';
  static const Color customerPrimaryColor = Color(0xFF741526);
  static const MaterialColor customerSecondaryColor = Colors.grey;
  static const String ebsWSUrl = 'https://apitest.newsan.com.ar/custexp/last-sales';
  static const String ebsWSToken = '028450faa154a7df0a69f15387b8a4f5';
}