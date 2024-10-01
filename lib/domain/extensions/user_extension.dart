import 'package:flappy_dash/domain/entities/dash_type.dart';
import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:nakama/nakama.dart';

extension UserExtensions on User {
  String get showingName {
    if (displayName.isNotNullOrBlank) {
      return displayName!;
    }
    return DashType.fromUserId(id).name;
  }
}
