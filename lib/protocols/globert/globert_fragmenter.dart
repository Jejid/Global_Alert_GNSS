// File A: lib/protocols/globert/globert_fragmenter.dart
// Fragmenter/Reassembler for Globert MEDIUM payloads
// Frame format (application-level fragmentation):
// [0] Marker (0xAB)        1 byte
// [1] Message ID (0..255)   1 byte
// [2] Seq (0..255)          1 byte
// [3] Total frames (1..255) 1 byte
// [4..] Chunk bytes
//
// This simple scheme allows interleaving multiple messages (different msgId)
// and reassembling them on reception. Keep header small (4 bytes).

import 'dart:typed_data';

class GlobertFragmenter {
  static const int marker = 0xAB;
  static const int headerSize = 4; // marker + msgId + seq + total

  /// Fragment a payload into frames with maxFrameSize bytes per frame.
  /// Each frame includes a 4-byte header as described above.
  /// messageId is a byte (0..255) chosen by the sender to identify the
  /// fragmented message sequence.
  static List<Uint8List> fragment(
    Uint8List payload,
    int maxFrameSize,
    int messageId,
  ) {
    if (maxFrameSize <= headerSize) {
      throw ArgumentError(
        'maxFrameSize must be greater than header size ($headerSize)',
      );
    }
    final chunkSize = maxFrameSize - headerSize;
    final totalFrames = (payload.length / chunkSize).ceil();
    if (totalFrames > 255) {
      throw ArgumentError(
        'payload too large to fragment with this maxFrameSize (>255 frames)',
      );
    }

    final frames = <Uint8List>[];
    for (var seq = 0; seq < totalFrames; seq++) {
      final start = seq * chunkSize;
      final end = (start + chunkSize) < payload.length
          ? (start + chunkSize)
          : payload.length;
      final chunk = payload.sublist(start, end);

      final frame = Uint8List(headerSize + chunk.length);
      frame[0] = marker & 0xFF;
      frame[1] = messageId & 0xFF;
      frame[2] = seq & 0xFF;
      frame[3] = totalFrames & 0xFF;
      frame.setRange(headerSize, headerSize + chunk.length, chunk);

      frames.add(frame);
    }
    return frames;
  }

  /// Given a list of chunks (ordered by seq) assembles the payload bytes.
  /// Expectation: frames are the raw frame bytes including header.
  static Uint8List assemble(List<Uint8List> frames) {
    if (frames.isEmpty) return Uint8List(0);
    // assume frames belong to the same messageId and are present for seq 0..total-1
    final total = frames[0][3];
    final chunks = <int, Uint8List>{};
    int sumLen = 0;
    for (final f in frames) {
      if (f.length < headerSize) throw ArgumentError('frame too short');
      final seq = f[2];
      final chunk = f.sublist(headerSize);
      chunks[seq] = chunk;
      sumLen += chunk.length;
    }
    // Concatenate in seq order
    final out = Uint8List(sumLen);
    var offset = 0;
    for (var i = 0; i < total; i++) {
      final c = chunks[i];
      if (c == null) throw ArgumentError('missing frame seq $i');
      out.setRange(offset, offset + c.length, c);
      offset += c.length;
    }
    return out;
  }
}
