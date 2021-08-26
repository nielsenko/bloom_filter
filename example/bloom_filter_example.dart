import 'dart:math';

import 'package:bloom_filter/bloom_filter.dart';

void main() {
  const max = 1 << 32;
  final b = BloomFilter<int>(10000, 7, hashCodes: (i) => extendedDoubleHash(sha1hashes(i)));
  final r = Random(42);
  for (var i = 0; i < 1000; ++i) {
    final e = r.nextInt(max);
    b.add(e);
    assert(b.contains(e));
  }
}
