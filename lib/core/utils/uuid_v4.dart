import 'dart:math';

final _uuidV4Pattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

/// Returns true when [value] looks like a UUID v4 string.
bool isUuidV4(String value) => _uuidV4Pattern.hasMatch(value);

/// Generates a UUID v4 without adding a package dependency.
String generateUuidV4([Random? random]) {
  final rng = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int byte) => byte.toRadixString(16).padLeft(2, '0');
  final hexBytes = bytes.map(hex).join();
  return '${hexBytes.substring(0, 8)}-'
      '${hexBytes.substring(8, 12)}-'
      '${hexBytes.substring(12, 16)}-'
      '${hexBytes.substring(16, 20)}-'
      '${hexBytes.substring(20)}';
}
