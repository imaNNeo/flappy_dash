extension NullableStringExtension on String? {
  bool get isNullOrBlank => this == null || this!.isBlank;
  bool get isNotNullOrBlank => !isNullOrBlank;
}

extension StringExtension on String {
  bool get isBlank => trim().isEmpty;
  bool get isNotBlank => !isBlank;
}
