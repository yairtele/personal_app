import 'dart:convert';
import 'package:http/http.dart';
import '../config/cache.dart';
import '../config/configuration.dart';
import '../services/business/song.dart';
import '../services/sp_ws/web_service_exception.dart';

String getPerformancesURL(usernameId, offset) {
  return 'https://www.smule.com/api/profile/performances?accountId=${usernameId}&appUid=sing&offset=${offset}';//el offset cuenta de a 15
}

String getInitialPerformancesURL(usernameId){
  return getPerformancesURL(usernameId, '0');
}

Future<List<Song>> getSmuleSongs(usernameId) async {
  final response = await get(Uri.parse(getInitialPerformancesURL(usernameId)));

  if(response.statusCode >= 200 && response.statusCode < 300){

    final jsonBody = parseResponse(response);

    final entries = jsonBody['list'];

    final songs = entries.map<Song>((e) => Song.fromJSON(e)).toList();

    final songsFiltered = await filterSongs(songs);

    return songsFiltered;
  } else {
    throw WebServiceException(
        'Hubo un problema obteniendo la lista de canciones. Status Code: ${response
            .statusCode}. Error message: ${response.reasonPhrase}',
        response: response
    );
  }
}

Map<String, dynamic> parseResponse(Response response) {
  return jsonDecode(const Utf8Decoder().convert(response.bodyBytes));
}

Future<List<Song>> filterSongs(List<Song> songs) async {
  //se filtran las que sean performedBy el otro user (x ahora esto nomas)
  //+ las que sean performedBy el user actual y en other_performers aparezca el otro user

  final actualUser = await Cache.getUserName();

  final usersData =  Configuration.usersJson.entries;
  final filteredUsersData = usersData.where((e) => actualUser != e.key);
  final filteredSmuleUsers = filteredUsersData.map((u) => u.value['smuleUser']).toList();
  //TODO: Validar que sea un solo resultado
  final otherPerformerUser = filteredSmuleUsers[0];

  final songsFiltered = songs.where((s) => s.performedBy == otherPerformerUser).toList();

  return songsFiltered;
}