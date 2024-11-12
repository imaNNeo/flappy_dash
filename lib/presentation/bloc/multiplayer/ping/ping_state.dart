part of 'ping_cubit.dart';

class PingState extends Equatable {
  const PingState({
    this.lastPingSentAt,
    this.currentPing,
  });

  final ({String pingId, DateTime time})? lastPingSentAt;
  final ({int total, int send, int recieve})? currentPing;

  PingState copyWith({
    ValueWrapper<({String pingId, DateTime time})>? lastPingSentAt,
    ValueWrapper<({int total, int send, int recieve})?>? currentPing,
  }) =>
      PingState(
        lastPingSentAt:
            lastPingSentAt != null ? lastPingSentAt.value : this.lastPingSentAt,
        currentPing: currentPing != null ? currentPing.value : this.currentPing,
      );

  @override
  List<Object?> get props => [
        lastPingSentAt,
        currentPing,
      ];
}
