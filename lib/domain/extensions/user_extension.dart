import 'package:flappy_dash/domain/extensions/string_extension.dart';
import 'package:nakama/nakama.dart';

extension UserExtensions on User {
  String get showingName {
    if (displayName.isNotNullOrBlank) {
      return displayName!;
    }

    if (username.isNotNullOrBlank) {
      return username!;
    }

    throw StateError('User must have username!');
  }
}
