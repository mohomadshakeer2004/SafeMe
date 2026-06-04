import 'package:intl/intl.dart';

/// Parses complaint/appointment dates stored in RTDB (ISO, [DateTime.toString], or "Jun 20, 2022").
DateTime? tryParseStoredDate(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;

  try {
    return DateTime.parse(text);
  } catch (_) {}

  const patterns = [
    'MMM d, yyyy h:mm a',
    'MMM dd, yyyy h:mm a',
    'MMM d, yyyy HH:mm',
    'MMM dd, yyyy HH:mm',
    'MMM d, yyyy',
    'MMM dd, yyyy',
    'dd/MM/yyyy HH:mm',
    'dd/MM/yyyy',
    'yyyy-MM-dd HH:mm:ss.SSS',
    'yyyy-MM-dd HH:mm:ss',
    'yyyy-MM-dd',
  ];

  for (final pattern in patterns) {
    try {
      return DateFormat(pattern).parse(text);
    } catch (_) {}
  }

  return null;
}

String formatStoredDate(
  dynamic value, {
  String pattern = 'yyyy-MM-dd',
  String fallback = '-',
}) {
  final parsed = tryParseStoredDate(value);
  if (parsed == null) {
    final raw = value?.toString().trim();
    return (raw == null || raw.isEmpty) ? fallback : raw;
  }
  return DateFormat(pattern).format(parsed);
}
