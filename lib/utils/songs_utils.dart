import '../config/cache.dart';
import '../config/configuration.dart';

class SongsUtils {
  static Future<String?> getSmuleUser(usernameSmuleId) async {
    //final actualUser = await Cache.getUserName();

    final usersData =  Configuration.usersJson.entries;
    final filteredUsersData = usersData.where((e) => usernameSmuleId == e.value['smuleId']);
    final filteredSmuleUsers = filteredUsersData.map((u) => u.value['smuleUser']).toList();

    if (filteredSmuleUsers.length == 1) {
      return filteredSmuleUsers[0];
    } else {
      throw Exception('More than one other user found.');
    }
  }

  static Future<String?> getOtherSmuleUser(usernameSmuleId) async {
    //final actualUser = await Cache.getUserName();

    final usersData =  Configuration.usersJson.entries;
    final filteredUsersData = usersData.where((e) => usernameSmuleId != e.value['smuleId']);
    final filteredSmuleUsers = filteredUsersData.map((u) => u.value['smuleUser']).toList();

    if (filteredSmuleUsers.length == 1) {
      return filteredSmuleUsers[0];
    } else {
      throw Exception('More than one other user found.');
    }
  }

  static Future<String?> getOtherSmuleUserId(usernameSmuleId) async {
    //final actualUser = await Cache.getUserName();

    final usersData =  Configuration.usersJson.entries;
    final filteredUsersData = usersData.where((e) => usernameSmuleId != e.value['smuleId']);
    final filteredSmuleUsers = filteredUsersData.map((u) => u.value['smuleId']).toList();

    if (filteredSmuleUsers.length == 1) {
      return filteredSmuleUsers[0];
    } else {
      throw Exception('More than one other user found.');
    }
  }
}