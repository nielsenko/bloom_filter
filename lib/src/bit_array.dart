import 'dart:typed_data';

class BitArray {
  static const int wordSize = 64;

  final Uint64List words;
  final int size;

  const BitArray._(this.words, this.size);

  BitArray(int size) : this._(Uint64List((size / wordSize).ceil()), size);

  bool operator [](int index) {
    final word = index ~/ wordSize;
    final bit = index % wordSize;
    return words[word] & (1 << bit) != 0;
  }

  void operator []=(int index, bool value) {
    final word = index ~/ wordSize;
    final bit = index % wordSize;
    if (value) {
      words[word] |= (1 << bit);
    } else {
      words[word] &= ~(1 << bit);
    }
  }
}
