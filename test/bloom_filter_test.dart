import 'dart:math';

import 'package:bloom_filter/bloom_filter.dart';
import 'package:test/test.dart';

double error(BloomFilter b, int n) {
  const maxValue = 1 << 32;
  final r = Random(42);
  final exact = <int>{};
  for (var i = 0; i < n; ++i) {
    final e = r.nextInt(maxValue);
    b.add(e);
    exact.add(e);
  }

  var falsePositives = 0;
  final candidates = min((1 / b.expectedError(n) * 100).ceil(), 1000000); // expect at most 100 false positives
  var i = candidates;
  while (i > 0) {
    final e = r.nextInt(maxValue);
    if (!exact.contains(e)) {
      --i; // found a negative ..
      if (b.contains(e)) ++falsePositives; // .. but we think it is positive
    } else {
      print('.');
    }
  }

  final actualError = falsePositives / candidates;
  return actualError;
}

void main() {
  test('add, then lookup', () {
    const max = 1 << 32;
    final b = BloomFilter<int>(10000, 7);
    final r = Random(42);
    for (var i = 0; i < 1000; ++i) {
      final e = r.nextInt(max);
      b.add(e);
      expect(b.contains(e), isTrue, reason: '$i');
    }
  });

  test('(de)serialize', () {
    final r = Random(42);
    final bytes = List<int>.generate(10000, (index) => r.nextInt(256));
    expect(BloomFilter.fromBytes(bytes, 7).toBytes(), bytes);
  });

  group('false positives', () {
    final hashes = <String, Iterable<int> Function(int)?>{
      'default': null,
      'hashCode and fnv1a64': (i) => extendedDoubleHash([i.hashCode, fnv1a64(i)]),
      'md5': (i) => extendedDoubleHash(md5hashes(i)),
      'sha1': (i) => extendedDoubleHash(sha1hashes(i)),
    };

    for (final h in hashes.entries) {
      test(h.key, () {
        final m = 10000;
        final n = 1000;
        final k = (m / n * ln2).ceil();
        final b = BloomFilter<int>(m, k, hashCodes: h.value);
        final expectedError = b.expectedError(n);
        final actualError = error(b, n);
        // actual error should at most exceed optimal error by 50%
        expect(actualError, lessThanOrEqualTo(expectedError * 1.5));
      });
    }
  });
}
