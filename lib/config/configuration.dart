import 'dart:ui';
import 'package:flutter/material.dart';

class Configuration{
  static const Color customerPrimaryColor = Color(0xFF99cfe0);//TODO: Esto será personalizado por usuario
  static const Color customerSecondaryColor = Color(0xFFce5eb3);//TODO: Esto será personalizado por usuario
  static const String photosFolderName = 'personal_app_photos';
  static const String photosURL = 'https://drive.google.com/uc?export=view&id=<<photoId>>';
  static const String songsURL = 'https://www.smule.com';
  //TODO: PAPP - Pasar a archivo o db
  static const usersJson = {
    'marystique': {
      'password': '050700',
      'smuleUser': 'Marystique',
      'smuleId': '2876977630',
      'email': 'marie.brugiroux@outlook.fr',
      'firstName': 'Marie',
      'lastName': 'Brugiroux'
    },
    'yairtele': {
      'password': '020496',
      'smuleUser': 'yairtele96',
      'smuleId': '39223017',
      'email': 'yairtele@yahoo.com.ar',
      'firstName': 'Yair',
      'lastName': 'Telezon'
    },
    /*'genapardo': {
      'password': '140798',
      'smuleUser': 'GenaPardoo',
      'smuleId': '2810191138'
    }*/
  };
}

