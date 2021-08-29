import 'dart:collection';
import 'dart:typed_data';

class BitArray {
  static const int wordSize = Uint64List.bytesPerElement * 8; // in bits

  final Uint64List words;
  final int size;

  const BitArray._(this.words, this.size);

  BitArray(int size) : this._(Uint64List((size / wordSize).ceil()), size);

  BitArray.fromBytes(List<int> bytes)
      : this._(
          Uint8List.fromList(bytes).buffer.asUint64List(),
          bytes.length * 8,
        );

  List<int> toBytes() => UnmodifiableListView(words.buffer.asUint8List());

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
