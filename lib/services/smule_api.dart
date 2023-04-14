import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:marieyayo/utils/ui/working_indicator_dialog.dart';
import 'package:path_provider/path_provider.dart';

import '../ui/ui_helper.dart';

Future<String> getMediaType(arg) async {
  if (!(arg.runtimeType is String)) {
    throw Exception('URL required!');
  }

  final response = await http.get(arg);
  final responseBody = response.body;

  try {
    return responseBody.split('twitter:player:stream:content_type" content="')[1].split('">')[0];
  }catch(e){
    throw Exception('Requested audio/video not available');
  }
}

Future<String> fetchLink(arg) async {
  if (!(arg.runtimeType is String)) {
    throw Exception('URL required!');
  }

  final response = await http.get(arg);
  final responseBody = response.body;

  try {
    return responseBody.split('twitter:player:stream" content="')[1].split('">')[0].replaceAll('amp', '');
  }catch(e){
    throw Exception('Requested audio/video not available');
  }
}

Future<dynamic> getVideoAndAudio(String link, context) async {
  final url = link.split('www').join('https://www');

  if (isURL(url) == true) {

    late ConnectivityResult connectivityStatus;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      connectivityStatus = await Connectivity().checkConnectivity();
    } on PlatformException catch (_) {
      throw Exception('Couldn\'t check connectivity status');
    }

    if (connectivityStatus == ConnectivityResult.none){
      throw Exception('Please check your internet connection.');
    } else {
        WorkingIndicatorDialog().show(context, text: 'Smuling...');

        final response = await http.get(Uri.parse(url));
        final responseBody = response.body;
        final mediaType = responseBody.split('twitter:player:stream:content_type" content="')[1].split('">')[0].replaceAll('/mp4', '');
        final mediaSource = responseBody.split('twitter:player:stream" content="')[1].split('">')[0];
        final fetchMainSource = mediaSource.replaceAll('amp', '');

        WorkingIndicatorDialog().dismiss();
        WorkingIndicatorDialog().show(context, text: 'Fetching downloadable link');

        final localFolderPath = (await getApplicationDocumentsDirectory()).path;

        var saveMedia;
        if (mediaType == 'audio') {
          saveMedia = '.m4a';
        } else {
          saveMedia = '.mp4';
        }

        final localFilePath = '${localFolderPath}/${songName(url)}${saveMedia}';

        var res;

        try{

          WorkingIndicatorDialog().dismiss();
          WorkingIndicatorDialog().show(context, text: 'Downloading ${mediaType}. Please wait...');

          res = await Dio().download(fetchMainSource, localFilePath,
              onReceiveProgress: (value1, value2) {}
          );

          WorkingIndicatorDialog().dismiss();
          UIHelper.showSuccessfulSnackBar('Downloading finished', context);

        } catch(_){
          throw Exception('Song couldn\'t be downloaded. Check free storage space.');//Broken link or maybe the song has been removed!
        }

        return res;
    }
  } else {
    throw Exception('Tried to download from invalid URL');
  }
}

bool isURL(url){
  return true;//en principio siempre va a ser true ya que siempre se invoca con un link previamente obtenido
}

String songName(String url){
  return url.split('/')[4];
}