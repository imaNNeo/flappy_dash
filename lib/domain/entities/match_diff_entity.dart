import 'package:equatable/equatable.dart';

import 'match_diff_info_entity.dart';

class MatchDiffEntity with EquatableMixin {
  final int tickTimeStamp;
  final int tickNumber;
  final List<MatchDiffInfoEntity> diffInfo;

  // fromJson
  factory MatchDiffEntity.fromJson(Map<String, dynamic> json) {
    final tickTimeStamp = json['tickTimeStamp'] as int;
    final tickNumber = json['tickNumber'] as int;
    final diffInfo = (json['diffInfo'] as List)
        .map((e) => MatchDiffInfoEntity.fromJson(e as Map<String, dynamic>))
        .toList();
    return MatchDiffEntity(
      tickTimeStamp: tickTimeStamp,
      tickNumber: tickNumber,
      diffInfo: diffInfo,
    );
  }

  MatchDiffEntity({
    required this.tickTimeStamp,
    required this.tickNumber,
    required this.diffInfo,
  });

  @override
  List<Object?> get props => [
        tickTimeStamp,
        tickNumber,
        diffInfo,
      ];
}
