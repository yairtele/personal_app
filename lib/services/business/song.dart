
import 'package:flutter/cupertino.dart';

import '../athento/athento_field_name.dart';

class Song {
  String key; //performance key (id)
  String title; //song title (name of song)
  String type; //performance type (audio or video)
  String artist; //song artist
  String? message; //message of the song (description)
  String createdAt; //date of song creation
  String ensembleType; //ensemble type (DUET or SOLO or COLAB)
  String coverURL; //song's photo
  String webURL; //Configuration.songsURL+webURL to go to the performance media //we must extract the m4a for audios and the mp4 for videos
  String performedBy; //creator of the song
  //String? otherPerformers;//it is a list, but it's not coming with a value when consulting from the own user that created the duet

  Song(
      {
        required this.key,
        required this.title,
        required this.type,
        required this.artist,
        this.message,
        required this.createdAt,
        required this.ensembleType,
        required this.coverURL,
        required this.webURL,
        required this.performedBy,
        //this.otherPerformers
      }
    );

  Map<String, dynamic> toJSON() {
    return {
      'key': key,
      'title': title,
      'type': type,
      'artist': artist,
      'message': message,
      'createdAt': createdAt,
      'ensembleType': ensembleType,
      'coverURL': coverURL,
      'webURL': webURL,
      'performedBy': performedBy,
      //'otherPerformers': otherPerformers
    };
  }

  Song.fromJSON(Map<String, dynamic> json) :
        key = json['key'],
        title = json['title'],
        type = json['type'],
        artist = json['artist'],
        message = json['message'],
        createdAt = json['created_at'],
        ensembleType = json['ensemble_type'],
        coverURL = json['cover_url'],
        webURL = json['web_url'],
        performedBy = json['performed_by_url'].replaceAll('/', '');
        //otherPerformers = json['other_performers'];
}