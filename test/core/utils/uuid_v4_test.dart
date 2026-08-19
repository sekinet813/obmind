import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/core/utils/uuid_v4.dart';

void main() {
  test('generateUuidV4 matches the UUID v4 layout', () {
    final value = generateUuidV4(Random(1));

    expect(isUuidV4(value), isTrue);
  });

  test('generateUuidV4 values differ across calls', () {
    final random = Random(2);

    expect(generateUuidV4(random), isNot(generateUuidV4(random)));
  });
}
