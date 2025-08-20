// lib/protocols/globert/globert_message.dart
// Globert — MEDIUM profile (20 bytes) encoder/decoder for Flutter
// Author: Edwin and Coni (assistant)
// Description:
//   - Implements the MEDIUM profile (20 bytes / 160 bits) payload format
//     used by the Globert MVP.
//   - Provides `GlobertMessage.fromBytes(...)` and `toBytes()` for parsing
//     and serializing messages.
//   - Includes helpers: int24 encoding/decoding, 6-bit text packing, CRC16
//     (CCITT‑False), timestamp helpers and convenience getters.
//   - At the bottom there's a short commented snippet showing how to integrate
//     this class with a GNSS stream handler (gnss_stream_service).

import 'dart:math' as math;
import 'dart:typed_data';

class GlobertMessage {
  // Public fields (primitive representation)
  final int version; // 4 bits (0..15)
  final int flags; // 4 bits (0..15)
  final int alertType; // 1 byte (0..255)
  final int latInt24; // signed int24 representation for latitude
  final int lonInt24; // signed int24 representation for longitude
  final int radiusMeters; // 1 byte (0..255)
  final int timestampMinutes; // 2 bytes (0..65535)
  final String shortText; // human readable short text (decoded from 7 bytes)

  // Internal flag set during decode
  final bool crcValid;

  GlobertMessage._(
    this.version,
    this.flags,
    this.alertType,
    this.latInt24,
    this.lonInt24,
    this.radiusMeters,
    this.timestampMinutes,
    this.shortText,
    this.crcValid,
  );

  /// Create with human-friendly parameters; timestamp generated from now UTC.
  factory GlobertMessage.create({
    int version = 1,
    int flags = 0x1, // bit0: 6-bit packing
    required int alertType,
    required double latitudeDeg,
    required double longitudeDeg,
    required int radiusMeters,
    String shortText = '',
  }) {
    final lat = _encodeLatDegToInt24(latitudeDeg, isLat: true);
    final lon = _encodeLatDegToInt24(longitudeDeg, isLat: false);
    final ts = _minutesSinceRef(DateTime.now().toUtc());
    return GlobertMessage._(
      version & 0x0F,
      flags & 0x0F,
      alertType & 0xFF,
      lat,
      lon,
      radiusMeters & 0xFF,
      ts & 0xFFFF,
      shortText,
      true, // created locally => CRC implied valid after serialization
    );
  }

  // ================= Public API =================

  /// Serialize to a 20-byte payload (List<int> or Uint8List)
  Uint8List toBytes() {
    final out = Uint8List(20);

    // Header (1 byte)
    out[0] = ((version & 0x0F) << 4) | (flags & 0x0F);

    // AlertType
    out[1] = alertType & 0xFF;

    // Lat int24 -> bytes 2..4
    _writeInt24(out, 2, latInt24);

    // Lon int24 -> bytes 5..7
    _writeInt24(out, 5, lonInt24);

    // Radius -> byte 8
    out[8] = radiusMeters & 0xFF;

    // Timestamp minutes -> bytes 9..10
    out[9] = (timestampMinutes >> 8) & 0xFF;
    out[10] = timestampMinutes & 0xFF;

    // ShortText packed into bytes 11..17 (7 bytes)
    final packed = _pack6(shortText, 7);
    for (var i = 0; i < 7; i++) {
      out[11 + i] = packed[i];
    }

    // CRC16 over bytes 0..17 -> bytes 18..19
    final crc = _crc16(out, 0, 18);
    out[18] = (crc >> 8) & 0xFF;
    out[19] = crc & 0xFF;

    return out;
  }

  /// Parse 20 bytes; returns a GlobertMessage instance and crcValid flag.
  /// Throws if length != 20.
  static GlobertMessage fromBytes(List<int> data) {
    if (data.length != 20) {
      throw ArgumentError('Globert MEDIUM profile requires exactly 20 bytes');
    }
    final bytes = Uint8List.fromList(data);

    // Validate CRC
    final receivedCrc = ((bytes[18] & 0xFF) << 8) | (bytes[19] & 0xFF);
    final calcCrc = _crc16(bytes, 0, 18);
    final crcOk = receivedCrc == calcCrc;

    final header = bytes[0];
    final version = (header >> 4) & 0x0F;
    final flags = header & 0x0F;

    final alertType = bytes[1] & 0xFF;

    final latInt24 = _readInt24(bytes, 2);
    final lonInt24 = _readInt24(bytes, 5);

    final radius = bytes[8] & 0xFF;

    final timestamp = ((bytes[9] & 0xFF) << 8) | (bytes[10] & 0xFF);

    final shortBytes = bytes.sublist(11, 18);
    final shortText = _unpack6(shortBytes);

    return GlobertMessage._(
      version,
      flags,
      alertType,
      latInt24,
      lonInt24,
      radius,
      timestamp,
      shortText,
      crcOk,
    );
  }

  // ================= Convenience getters =================

  /// Latitude in degrees (approx. precision ~2–3 m per LSB as designed)
  double get latitudeDeg => _decodeInt24ToDeg(latInt24, isLat: true);

  /// Longitude in degrees
  double get longitudeDeg => _decodeInt24ToDeg(lonInt24, isLat: false);

  /// Timestamp as DateTime UTC (reconstructed from minutes-since-ref)
  DateTime get timestampDateTimeUtc =>
      _refEpoch.add(Duration(minutes: timestampMinutes));

  /// whether CRC validated on decode
  bool get isCrcValid => crcValid;

  /// Map representation (convenient to convert to your AlertMessageModel)
  Map<String, dynamic> toMap() => {
    'version': version,
    'flags': flags,
    'alertType': alertType,
    'latitude': latitudeDeg,
    'longitude': longitudeDeg,
    'radiusMeters': radiusMeters,
    'timestampUtc': timestampDateTimeUtc.toIso8601String(),
    'shortText': shortText,
    'crcValid': crcValid,
  };

  // ================= Implementation details =================

  // Reference epoch for timestamp minutes. Keep consistent across devices.
  static final DateTime _refEpoch = DateTime.utc(2025, 1, 1);

  static int _minutesSinceRef(DateTime utcNow) {
    final diff = utcNow.toUtc().difference(_refEpoch);
    return diff.inMinutes % 65536;
  }

  // Scale constants chosen so int24 maps to lat/lon with sufficient resolution.
  // int24 has 24 bits; we reserve signed range ±(2^23 - 1).
  static const double _scaleLat = ((1 << 23) - 1) / 90.0; // maps ±90°
  static const double _scaleLon = ((1 << 23) - 1) / 180.0; // maps ±180°

  static int _encodeLatDegToInt24(double deg, {required bool isLat}) {
    final scale = isLat ? _scaleLat : _scaleLon;
    final v = (deg * scale).round();
    final min = -(1 << 23);
    final max = (1 << 23) - 1;
    final clamped = math.max(min, math.min(max, v));
    return clamped & 0xFFFFFF; // store as 24 bits
  }

  static double _decodeInt24ToDeg(int int24, {required bool isLat}) {
    final signed = _int24ToSigned(int24);
    final scale = isLat ? _scaleLat : _scaleLon;
    return signed / scale;
  }

  static int _int24ToSigned(int x) {
    x &= 0xFFFFFF;
    if ((x & 0x800000) != 0) {
      return x | ~0xFFFFFF; // sign-extend
    }
    return x;
  }

  static void _writeInt24(Uint8List out, int offset, int value) {
    final v = value & 0xFFFFFF;
    out[offset] = (v >> 16) & 0xFF;
    out[offset + 1] = (v >> 8) & 0xFF;
    out[offset + 2] = v & 0xFF;
  }

  static int _readInt24(Uint8List d, int offset) {
    final b0 = d[offset] & 0xFF;
    final b1 = d[offset + 1] & 0xFF;
    final b2 = d[offset + 2] & 0xFF;
    final v = (b0 << 16) | (b1 << 8) | b2;
    return v;
  }

  // ================= 6-bit packing for shortText =================
  // Alphabet: 64 symbols (space + A-Z + a-z + 0-9 + two punctuation)
  static const String _sixBitAlphabet =
      ' ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-';

  static List<int> _pack6(String text, int outLenBytes) {
    final maxChars = (outLenBytes * 8) ~/ 6; // floor
    final padded = text.padRight(maxChars).substring(0, maxChars);
    int acc = 0;
    int accBits = 0;
    final out = <int>[];

    for (final ch in padded.split('')) {
      final idx = _sixBitAlphabet.indexOf(ch);
      final v = idx >= 0 ? idx : 0; // default to space
      acc = (acc << 6) | (v & 0x3F);
      accBits += 6;
      while (accBits >= 8) {
        final shift = accBits - 8;
        final byte = (acc >> shift) & 0xFF;
        out.add(byte);
        acc &= (1 << shift) - 1;
        accBits -= 8;
        if (out.length == outLenBytes) break;
      }
      if (out.length == outLenBytes) break;
    }

    if (out.length < outLenBytes && accBits > 0) {
      final byte = (acc << (8 - accBits)) & 0xFF;
      out.add(byte);
    }
    while (out.length < outLenBytes) out.add(0);
    return out;
  }

  static String _unpack6(List<int> bytes) {
    int acc = 0;
    int accBits = 0;
    final codes = <int>[];
    for (final b in bytes) {
      acc = (acc << 8) | (b & 0xFF);
      accBits += 8;
      while (accBits >= 6) {
        final shift = accBits - 6;
        final v = (acc >> shift) & 0x3F;
        codes.add(v);
        acc &= (1 << shift) - 1;
        accBits -= 6;
      }
    }
    final sb = StringBuffer();
    for (final c in codes) {
      sb.write(c >= 0 && c < _sixBitAlphabet.length ? _sixBitAlphabet[c] : ' ');
    }
    return sb.toString().trimRight();
  }

  // ================= CRC16 (CCITT-FALSE) =================
  // poly: 0x1021, init: 0xFFFF, xorOut: 0x0000
  static int _crc16(Uint8List data, int offset, int length) {
    int crc = 0xFFFF;
    for (int i = offset; i < offset + length; i++) {
      crc ^= (data[i] & 0xFF) << 8;
      for (int j = 0; j < 8; j++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc & 0xFFFF;
  }

  // Add inside GlobertMessage class (globert_message.dart)

  /// Convert decoded GlobertMessage into the JSON map expected by AlertMessage.fromJson
  Map<String, dynamic> toAlertJson({String? idPrefix}) {
    final id = idPrefix ?? 'globert-${timestampMinutes}-${alertType}';
    return {
      'id': id,
      // Convert numeric alertType to string category (customize mapping below)
      'type': _alertTypeToString(alertType),
      'title': shortText.isNotEmpty
          ? shortText
          : _alertTitleFromType(alertType),
      'scope': 'zonal', // adjust policy if needed
      'target': null,
      'timestamp': timestampDateTimeUtc.toIso8601String(),
      'message': shortText,
      'regions': null,
      'locations': [
        {
          'lat': latitudeDeg,
          'lon': longitudeDeg,
          // convert meters -> km for your model
          'radius_km': (radiusMeters / 1000.0),
        },
      ],
      'language': 'es',
      'source': 'globert',
      'priority': _alertPriorityFromType(alertType),
      // 'valid_until': null // include if you generate one
    };
  }

  /// Helper: map numeric alertType -> string
  String _alertTypeToString(int code) {
    switch (code) {
      case 1:
        return 'evacuation';
      case 2:
        return 'tsunami';
      case 3:
        return 'earthquake';
      case 4:
        return 'fire';
      case 5:
        return 'rescue';
      case 6:
        return 'missing';
      default:
        return 'unknown';
    }
  }

  /// Helper: human title fallback
  String _alertTitleFromType(int code) {
    switch (code) {
      case 1:
        return 'Evacuation';
      case 2:
        return 'Tsunami Alert';
      case 3:
        return 'Earthquake';
      case 4:
        return 'Fire';
      case 5:
        return 'Rescue Operation';
      case 6:
        return 'Missing Person';
      default:
        return 'Alert';
    }
  }

  /// Helper: default priority mapping
  String _alertPriorityFromType(int code) {
    switch (code) {
      case 3:
      case 2:
        return 'critical';
      case 4:
        return 'high';
      default:
        return 'normal';
    }
  }
}

// Note: if your GNSS listener receives frames smaller (or fragmented), create a
// reassembly buffer that concatenates frames and calls GlobertMessage.fromBytes
// when a full 20‑byte payload is available. Consider adding a small frame header
// (frameID + totalFrames) in front of the payload if you need to transmit in
// segmented frames.

// ================= End of file =================
