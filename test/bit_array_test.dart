import 'dart:math';

import 'package:bloom_filter/src/bit_array.dart';
import 'package:test/test.dart';

void main() {
  void checkRange(BitArray a, int start, int stop, bool value) {
    for (var i = start; i <= stop; ++i) {
      expect(a[i], value, reason: 'index $i');
    }
  }

  test('set, read, unset, and read', () {
    const max = 100; // > 64
    final a = BitArray(max);
    for (var i = 0; i < max; ++i) {
      a[i] = true;
      checkRange(a, 0, i, true);
      checkRange(a, i + 1, max - 1, false);
    }
    for (var i = 0; i < max; ++i) {
      a[i] = false;
      checkRange(a, 0, i, false);
      checkRange(a, i + 1, max - 1, true);
    }
  });

  test('(de)serialize', () {
    final r = Random(42);
    final bytes = List<int>.generate(1000, (index) => r.nextInt(256));
    expect(BitArray.fromBytes(bytes).toBytes(), bytes);
  });
}
