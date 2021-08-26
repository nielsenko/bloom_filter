import 'dart:math';

import 'package:crypto/crypto.dart';
import 'dart:typed_data';

import 'bit_array.dart';

class BloomFilter<E> {
  final Iterable<int> Function(E) hash;
  final int k;
  BitArray filter;

  BloomFilter._(this.filter, this.k, Iterable<int> Function(E)? hashCodes)
      : hash = hashCodes ?? ((E e) => extendedDoubleHash(md5hashes(e.hashCode)));

  BloomFilter(int size, int k, {Iterable<int> Function(E)? hashCodes}) : this._(BitArray(size), k, hashCodes);

  int get size => filter.size;

  void add(E e) {
    for (final h in hashes(e)) {
      filter[h] = true;
    }
  }

  bool contains(E e) {
    for (var h in hashes(e)) {
      if (!filter[h]) return false;
    }
    return true;
  }

  double expectedError(int n) => pow(1 - exp(-k * n / size), k) as double;

  Iterable<int> hashes(E e) => hash(e).map((h) => h % size).takeExact(k);
}

int fnv1a64(int n) {
  var hash = 0xcbf29ce484222325;
  for (var i = 0; i < 8; ++i) {
    final b = n & 0xf;
    hash ^= b;
    hash *= 0x100000001b3;
    n >>= 1;
  }
  return hash;
}

Uint64List sha1hashes(int n) {
  final bytes = ByteData(20)..setUint64(0, n);
  final digest = sha1.convert(bytes.buffer.asUint8List(0, 8)); // TODO: Optimize!
  final result = Uint64List(2)..buffer.asUint8List().setRange(0, 16, digest.bytes, 4);
  return result;
}

Uint64List md5hashes(int n) {
  final bytes = ByteData(16)..setUint64(0, n);
  final digest = md5.convert(bytes.buffer.asUint8List(0, 8)); // TODO: Optimize!
  final result = Uint64List(2)..buffer.asUint8List().setRange(0, 16, digest.bytes);
  return result;
}

/// Calculate an endless stream of hash values from two underlying hash functions
/// h0 and h1 using enhanced double hashing
///
/// hashes[i] = h0(x) + i*h1(x) + (i*i*i - i)/6.
///
/// See https://en.wikipedia.org/wiki/Double_hashing#Enhanced_double_hashing
/// and https://en.wikipedia.org/wiki/Bloom_filter
///
Iterable<int> extendedDoubleHash(List<int> h) sync* {
  var a = h[0];
  var b = h[1];
  var i = 0;
  while (true) {
    yield a;
    a += b; // add quadratic difference to get cubic
    b += i; // add linear difference to get quadratic
    ++i; // ++i adds constant difference to get linear
  }
}

extension IterableExtension<T> on Iterable<T> {
  Iterable<T> takeExact(int n) sync* {
    final it = iterator;
    for (var i = 0; i < n; ++i) {
      if (!it.moveNext()) throw RangeError.value(i);
      yield it.current;
    }
  }
}
