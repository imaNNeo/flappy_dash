import 'package:equatable/equatable.dart';

import 'match_diff_info_entity.dart';

class MatchDiffEntity with EquatableMixin {
  final int tickTimestamp;
  final int tickNumber;
  final List<MatchDiffInfoEntity> diffInfo;

  // fromJson
  factory MatchDiffEntity.fromJson(Map<String, dynamic> json) {
    final tickTimestamp = (json['tickTimestamp'] as num).toInt();
    final tickNumber = (json['tickNumber'] as num).toInt();
    final diffInfo = (json['diffInfo'] as List)
        .map((e) => MatchDiffInfoEntity.fromJson(e as Map<String, dynamic>))
        .toList();
    return MatchDiffEntity(
      tickTimestamp: tickTimestamp,
      tickNumber: tickNumber,
      diffInfo: diffInfo,
    );
  }

  MatchDiffEntity({
    required this.tickTimestamp,
    required this.tickNumber,
    required this.diffInfo,
  });

  @override
  List<Object?> get props => [
        tickTimestamp,
        tickNumber,
        diffInfo,
      ];
}
