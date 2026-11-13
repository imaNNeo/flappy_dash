import 'dart:ui';

import 'package:equatable/equatable.dart';

class StyledText with Equatable {
  final String text;
  final Color color;
  final bool isBold;

  StyledText(this.text, this.color, {this.isBold = false});

  @override
  List<Object?> get props => [text, color, isBold];
}
