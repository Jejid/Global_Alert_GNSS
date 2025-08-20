// test/protocols/globert_message_test.dart
// Unit tests for Globert MEDIUM profile: encode/decode and fragmenter roundtrip

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:global_alert_gnss/protocols/globert/globert_fragmenter.dart';
import 'package:global_alert_gnss/protocols/globert/globert_message.dart';

void main() {
  test('GlobertMessage encode -> decode roundtrip', () {
    final original = GlobertMessage.create(
      alertType: 2,
      latitudeDeg: 5.123456,
      longitudeDeg: -74.123456,
      radiusMeters: 250,
      shortText: 'EVAC N 2km',
    );

    final bytes = original.toBytes();
    expect(bytes.length, equals(20));

    final parsed = GlobertMessage.fromBytes(bytes.toList());
    expect(parsed.alertType, equals(original.alertType));
    expect(parsed.isCrcValid, isTrue);
    // lat/lon: allow small rounding diff
    expect(parsed.latitudeDeg, closeTo(original.latitudeDeg, 1e-4));
    expect(parsed.longitudeDeg, closeTo(original.longitudeDeg, 1e-4));
    expect(parsed.radiusMeters, equals(original.radiusMeters));
    expect(parsed.shortText, contains('EVAC'));
  });

  test('Fragmenter fragment -> shuffle -> assemble -> parse', () {
    final msg = GlobertMessage.create(
      alertType: 3,
      latitudeDeg: 1.2136,
      longitudeDeg: -77.2811,
      radiusMeters: 1000,
      shortText: 'TSUNAMI',
    );

    final payload = msg.toBytes();

    // Choose a small frame size to force fragmentation (header 4 bytes included)
    final frames = GlobertFragmenter.fragment(
      Uint8List.fromList(payload),
      10,
      7,
    );
    expect(frames.isNotEmpty, isTrue);

    // Shuffle frames to ensure assembler doesn't depend on order
    final shuffled = List<Uint8List>.from(frames);
    shuffled.shuffle(Random(42));

    final assembled = GlobertFragmenter.assemble(shuffled);
    expect(assembled.length, equals(payload.length));

    final parsed = GlobertMessage.fromBytes(assembled.toList());
    expect(parsed.alertType, equals(msg.alertType));
    expect(parsed.isCrcValid, isTrue);
    expect(parsed.shortText, contains('TSUNAMI'));
  });
}
