import 'dart:convert';
import 'package:http/http.dart';
import '../config/cache.dart';
import '../config/configuration.dart';
import '../services/business/song.dart';
import '../services/sp_ws/web_service_exception.dart';
import '../utils/songs_utils.dart';

String getPerformancesURL(usernameId, offset) {
  offset = offset.toString();
  return 'https://www.smule.com/api/profile/performances?accountId=${usernameId}&appUid=sing&offset=${offset}';//el offset cuenta de a 15
}

/*String getInitialPerformancesURL(usernameId){
  return getPerformancesURL(usernameId, '0');
}*/

Future<List<Song>> getSmuleSongs(usernameId) async {

  var offset = 0;
  var allSongs = <Song>[];

  while(true){

    final response = await get(Uri.parse(getPerformancesURL(usernameId, offset)));

    if(response.statusCode >= 200 && response.statusCode < 300){

      final jsonBody = parseResponse(response);

      final responseOffset = jsonBody['next_offset'];
      final entries = jsonBody['list'];

      final songs = entries.map<Song>((e) => Song.fromJSON(e)).toList();

      final songsFiltered = await filterSongs(songs);

      allSongs = [...allSongs, ...songsFiltered];

      if(responseOffset == -1) {
        //print('No more records to be processed.');
        break;
      }else{
        offset = responseOffset as int;
      }
    } else {
      throw WebServiceException(
          'There was an error when getting the songs list. Status Code: ${response
              .statusCode}. Error message: ${response.reasonPhrase}',
          response: response
      );
    }
  }

  return allSongs;
}

Map<String, dynamic> parseResponse(Response response) {
  return jsonDecode(const Utf8Decoder().convert(response.bodyBytes));
}

Future<List<Song>> filterSongs(List<Song> songs) async {

  //se filtran las que sean performedBy el otro user (x ahora esto nomas)
  //+ las que sean performedBy el user actual y en other_performers aparezca el otro user
  final performerUser = await SongsUtils.getSmuleUser();
  final otherPerformerUser = await SongsUtils.getOtherSmuleUser();
  final songsFiltered = songs.where((song){
    return song.performedBy == otherPerformerUser;// || song.performedBy == performerUser && song.otherPerformers == '';
  }).toList();


  return songsFiltered;
}