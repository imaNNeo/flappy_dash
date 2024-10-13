import 'package:nakama/nakama.dart';

/// In backend we send user_id, but in the client we parse it as userId
/// We need to use it [User.fromJson] method to parse the json
class UserJsonParser {
  static Map<String, dynamic> convertComingJson(Map<String, dynamic> json) {
    Map<String, dynamic> userMap = {};
    userMap['id'] = json['userId'];
    userMap['user_id'] = json['userId'];
    userMap['display_name'] = json['displayName'];
    userMap['avatar_url'] = json['avatarUrl'];
    userMap['lang_tag'] = json['langTag'];
    userMap['edge_count'] = json['edgeCount'];
    userMap['facebook_id'] = json['facebookId'];
    userMap['google_id'] = json['googleId'];
    userMap['gamecenter_id'] = json['gamecenterId'];
    userMap['steam_id'] = json['steamId'];
    userMap['apple_id'] = json['appleId'];
    userMap['facebook_instant_game_id'] = json['facebookInstantGameId'];
    userMap.remove('createTime');
    userMap.remove('updateTime');
    return userMap;
  }

  static Map<String, dynamic> convertOutgoingJson(Map<String, dynamic> user) {
    Map<String, dynamic> userMap = {};
    userMap['userId'] = user['id'];
    userMap['displayName'] = user['display_name'];
    userMap['avatarUrl'] = user['avatar_url'];
    userMap['langTag'] = user['lang_tag'];
    userMap['edgeCount'] = user['edge_count'];
    userMap['facebookId'] = user['facebook_id'];
    userMap['googleId'] = user['google_id'];
    userMap['gamecenterId'] = user['gamecenter_id'];
    userMap['steamId'] = user['steam_id'];
    userMap['appleId'] = user['apple_id'];
    userMap['facebookInstantGameId'] = user['facebook_instant_game_id'];
    return userMap;
  }
}
