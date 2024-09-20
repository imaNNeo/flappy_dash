import 'package:equatable/equatable.dart';
import 'package:flappy_dash/domain/extensions/user_extension.dart';
import 'package:nakama/nakama.dart';

class LeaderboardEntity with EquatableMixin {
  final LeaderboardRecordList _recordList;
  final Map<String, User> _userProfiles;

  int get length => _recordList.records.length;

  (LeaderboardRecord record, String name) operator [](int index) {
    final record = _recordList.records[index];
    final user = _userProfiles[record.ownerId!]!;
    return (record, user.showingName);
  }

  LeaderboardEntity({
    required LeaderboardRecordList recordList,
    required Map<String, User> userProfiles,
  })  : _userProfiles = userProfiles,
        _recordList = recordList,
        assert(recordList.records.length == userProfiles.length);

  @override
  List<Object?> get props => [
        _recordList,
        _userProfiles,
      ];
}
