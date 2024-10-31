import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/extensions/user_extension.dart';
import 'package:nakama/nakama.dart';

class LeaderboardEntity with EquatableMixin {
  final LeaderboardRecordList _recordList;
  final Map<String, User> _userProfiles;
  final String _currentUserId;

  LeaderboardRecord? get ownerRecord {
    if (_recordList.records == null) {
      return null;
    }
    for (final record in _recordList.records!) {
      if (record.ownerId == _currentUserId) {
        return record;
      }
    }
    return null;
  }

  int get length => _recordList.records!.length;

  (LeaderboardRecord record, String name) operator [](int index) {
    final record = _recordList.records![index];
    final user = _userProfiles[record.ownerId!]!;
    return (record, user.showingName);
  }

  LeaderboardEntity(
    this._recordList,
    this._userProfiles,
    this._currentUserId,
  ) : assert(_recordList.records!.length == _userProfiles.length);

  List<T> map<T>(T Function(LeaderboardRecord record, String name) f) =>
      List.generate(length, (index) => f(this[index].$1, this[index].$2));

  @override
  List<Object?> get props => [
        _recordList,
        _userProfiles,
        _currentUserId,
      ];
}
