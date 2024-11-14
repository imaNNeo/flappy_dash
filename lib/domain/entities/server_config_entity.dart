import 'package:equatable/equatable.dart';

class ServerConfigEntity with EquatableMixin {
  final int minimumAppVersion;

  ServerConfigEntity({
    required this.minimumAppVersion,
  });

  factory ServerConfigEntity.fromJson(Map<String, dynamic> json) =>
      ServerConfigEntity(
        minimumAppVersion: json['minimumAppVersion'] as int,
      );

  Map<String, dynamic> toJson() => {
        'minimumAppVersion': minimumAppVersion,
      };

  @override
  List<Object?> get props => [
        minimumAppVersion,
      ];
}
