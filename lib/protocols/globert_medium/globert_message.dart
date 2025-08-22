// lib/protocols/globert/globert_message.dart
// Globert — MEDIUM profile (20 bytes / 160 bits) encoder/decoder for Flutter
// Refactored to strictly conform to the Globert Protocol — MEDIUM Profile spec
// Author: Edwin and Coni (assistant)

import 'dart:math' as math;
import 'dart:typed_data';

class GlobertMessage {
  // Public fields (primitive representation)
  final int version; // 4 bits (0..15)
  final int flags; // 4 bits (0..15)
  final int alertType; // 1 byte (0..255)
  final int latInt24; // signed int24 representation for latitude
  final int lonInt24; // signed int24 representation for longitude
  final int radiusIndex; // 1 byte (0..255) — non‐linear index per spec
  final int timestampMinutes; // 2 bytes (0..65535)
  final String shortText; // human readable short text (decoded)
  final bool crcValid; // CRC check result on decode

  GlobertMessage._(
    this.version,
    this.flags,
    this.alertType,
    this.latInt24,
    this.lonInt24,
    this.radiusIndex,
    this.timestampMinutes,
    this.shortText,
    this.crcValid,
  );

  /// Create with human‐friendly parameters; timestamp generated from now UTC.
  factory GlobertMessage.create({
    int version = 1,
    int flags = 0x1, // bit0: 6‐bit packing
    required int alertType,
    required double latitudeDeg,
    required double longitudeDeg,
    required int radiusMeters, // supply meters, will snap to nearest index
    String shortText = '',
  }) {
    final lat = _encodeDegToInt24(latitudeDeg, isLat: true);
    final lon = _encodeDegToInt24(longitudeDeg, isLat: false);
    final idx = radiusToIndex(radiusMeters);
    final ts = _minutesSinceRef(DateTime.now().toUtc());
    return GlobertMessage._(
      version & 0x0F,
      flags & 0x0F,
      alertType & 0xFF,
      lat,
      lon,
      idx & 0xFF,
      ts & 0xFFFF,
      shortText,
      true, // locally created → CRC assumed valid
    );
  }

  // ================= Public API =================

  /// Serialize to a 20‐byte payload
  Uint8List toBytes() {
    final out = Uint8List(20);

    // Header (1)
    out[0] = ((version & 0x0F) << 4) | (flags & 0x0F);

    // AlertType (1)
    out[1] = alertType & 0xFF;

    // Lat int24 (3)
    _writeInt24(out, 2, latInt24);

    // Lon int24 (3)
    _writeInt24(out, 5, lonInt24);

    // RadiusIndex (1)
    out[8] = radiusIndex & 0xFF;

    // Timestamp minutes (2)
    out[9] = (timestampMinutes >> 8) & 0xFF;
    out[10] = timestampMinutes & 0xFF;

    // ShortText packed (7)
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

  /// Parse 20 bytes; throws if length != 20
  static GlobertMessage fromBytes(List<int> data) {
    if (data.length != 20) {
      throw ArgumentError('Globert MEDIUM profile requires exactly 20 bytes');
    }
    final bytes = Uint8List.fromList(data);

    // Validate CRC
    final received = ((bytes[18] & 0xFF) << 8) | (bytes[19] & 0xFF);
    final calculated = _crc16(bytes, 0, 18);
    final ok = received == calculated;

    final header = bytes[0];
    final ver = (header >> 4) & 0x0F;
    final flgs = header & 0x0F;

    final aType = bytes[1] & 0xFF;
    final lat24 = _readInt24(bytes, 2);
    final lon24 = _readInt24(bytes, 5);
    final idx = bytes[8] & 0xFF;
    final ts = ((bytes[9] & 0xFF) << 8) | (bytes[10] & 0xFF);

    final shortBytes = bytes.sublist(11, 18);
    final txt = _unpack6(shortBytes);

    return GlobertMessage._(ver, flgs, aType, lat24, lon24, idx, ts, txt, ok);
  }

  // ================= Convenience getters =================

  /// Latitude in degrees
  double get latitudeDeg => _decodeInt24ToDeg(latInt24, isLat: true);

  /// Longitude in degrees
  double get longitudeDeg => _decodeInt24ToDeg(lonInt24, isLat: false);

  /// Radius in meters (converted from index)
  int get radiusMeters => indexToRadius(radiusIndex);

  /// Timestamp as DateTime UTC
  DateTime get timestampDateTimeUtc =>
      _refEpoch.add(Duration(minutes: timestampMinutes));

  /// CRC validity from last decode
  bool get isCrcValid => crcValid;

  /// Map representation
  Map<String, dynamic> toMap() => {
    'version': version,
    'flags': flags,
    'alertType': alertType,
    'latitude': latitudeDeg,
    'longitude': longitudeDeg,
    'radiusIndex': radiusIndex,
    'radiusMeters': radiusMeters,
    'timestampUtc': timestampDateTimeUtc.toIso8601String(),
    'shortText': shortText,
    'crcValid': crcValid,
  };

  /// Convert to the JSON structure for your AlertMessageModel
  Map<String, dynamic> toAlertJson({String? idPrefix}) {
    final id = idPrefix ?? 'globert-$timestampMinutes-$alertType';
    return {
      'id': id,
      'type': _alertTypeToString(alertType),
      'title': shortText.isNotEmpty
          ? shortText
          : _alertTitleFromType(alertType),
      'scope': 'zonal',
      'target': null,
      'timestamp': timestampDateTimeUtc.toIso8601String(),
      'message': shortText,
      'regions': null,
      'locations': [
        {
          'lat': latitudeDeg,
          'lon': longitudeDeg,
          'radius_km': radiusMeters / 1000.0,
        },
      ],
      'language': 'es',
      'source': 'globert',
      'priority': _alertPriorityFromType(alertType),
    };
  }

  // ================= Implementation details =================

  static final DateTime _refEpoch = DateTime.utc(2025, 1, 1);

  static int _minutesSinceRef(DateTime utcNow) {
    final diff = utcNow.toUtc().difference(_refEpoch);
    return diff.inMinutes % 65536;
  }

  // ----------------- RadiusIndex mapping -----------------

  /// Convert an index [0..255] into meters per §5
  static int indexToRadius(int idx) {
    if (idx == 0) return 0;
    if (1 <= idx && idx <= 5) return idx * 10;
    if (6 <= idx && idx <= 10) {
      const table = {6: 100, 7: 200, 8: 400, 9: 600, 10: 800};
      return table[idx]!;
    }
    if (11 <= idx && idx <= 253) {
      return (idx - 10) * 1000;
    }
    if (idx == 254) return 500000;
    if (idx == 255) return 1000000;
    return 0;
  }

  /// Snap a meter value to the nearest RadiusIndex per §5
  static int radiusToIndex(int meters) {
    if (meters <= 0) return 0;
    // small radii
    const small = {10: 1, 20: 2, 30: 3, 40: 4, 50: 5};
    if (small.containsKey(meters)) return small[meters]!;
    // fine‐grain
    const fine = {100: 6, 200: 7, 400: 8, 600: 9, 800: 10};
    if (fine.containsKey(meters)) return fine[meters]!;
    // linear km
    if (meters <= 243000) {
      final idx = (meters / 1000.0).round() + 10;
      return idx.clamp(11, 253);
    }
    // macro
    if (meters <= 500000) return 254;
    return 255;
  }

  // ----------------- Lat/Lon int24 <-> deg -----------------

  static const double _scaleLat = ((1 << 23) - 1) / 90.0;
  static const double _scaleLon = ((1 << 23) - 1) / 180.0;

  static int _encodeDegToInt24(double deg, {required bool isLat}) {
    final scale = isLat ? _scaleLat : _scaleLon;
    final v = (deg * scale).round();
    final min = -(1 << 23);
    final max = (1 << 23) - 1;
    final clamped = math.max(min, math.min(max, v));
    return clamped & 0xFFFFFF;
  }

  static double _decodeInt24ToDeg(int raw, {required bool isLat}) {
    final signed = _int24ToSigned(raw);
    final scale = isLat ? _scaleLat : _scaleLon;
    return signed / scale;
  }

  static int _int24ToSigned(int x) {
    x &= 0xFFFFFF;
    if ((x & 0x800000) != 0) {
      return x | ~0xFFFFFF;
    }
    return x;
  }

  static void _writeInt24(Uint8List buf, int off, int val) {
    final v = val & 0xFFFFFF;
    buf[off] = (v >> 16) & 0xFF;
    buf[off + 1] = (v >> 8) & 0xFF;
    buf[off + 2] = v & 0xFF;
  }

  static int _readInt24(Uint8List buf, int off) {
    final b0 = buf[off] & 0xFF;
    final b1 = buf[off + 1] & 0xFF;
    final b2 = buf[off + 2] & 0xFF;
    return (b0 << 16) | (b1 << 8) | b2;
  }

  // ----------------- 6‐bit packing for shortText -----------------

  static const String _sixBitAlphabet =
      ' ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-';

  static List<int> _pack6(String text, int outLen) {
    final maxChars = (outLen * 8) ~/ 6;
    final padded = text.padRight(maxChars).substring(0, maxChars);
    var acc = 0;
    var accBits = 0;
    final out = <int>[];

    for (final ch in padded.split('')) {
      final idx = _sixBitAlphabet.indexOf(ch);
      final v = idx >= 0 ? idx : 0;
      acc = (acc << 6) | (v & 0x3F);
      accBits += 6;
      while (accBits >= 8 && out.length < outLen) {
        final shift = accBits - 8;
        out.add((acc >> shift) & 0xFF);
        acc &= (1 << shift) - 1;
        accBits -= 8;
      }
    }

    if (out.length < outLen && accBits > 0) {
      out.add((acc << (8 - accBits)) & 0xFF);
    }
    while (out.length < outLen) {
      out.add(0);
    }
    return out;
  }

  static String _unpack6(List<int> bytes) {
    var acc = 0;
    var accBits = 0;
    final codes = <int>[];
    for (final b in bytes) {
      acc = (acc << 8) | (b & 0xFF);
      accBits += 8;
      while (accBits >= 6) {
        final shift = accBits - 6;
        codes.add((acc >> shift) & 0x3F);
        acc &= (1 << shift) - 1;
        accBits -= 6;
      }
    }
    final sb = StringBuffer();
    for (final c in codes) {
      sb.write(c < _sixBitAlphabet.length ? _sixBitAlphabet[c] : ' ');
    }
    return sb.toString().trimRight();
  }

  // ----------------- CRC16 (CCITT‐FALSE) -----------------

  static int _crc16(Uint8List data, int offset, int length) {
    var crc = 0xFFFF;
    for (var i = offset; i < offset + length; i++) {
      crc ^= (data[i] & 0xFF) << 8;
      for (var j = 0; j < 8; j++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc & 0xFFFF;
  }

  // ----------------- AlertType helpers -----------------

  String _alertTypeToString(int code) {
    switch (code) {
      case 1:
        return 'earthquake';
      case 2:
        return 'tsunami';
      case 3:
        return 'evacuation';
      case 4:
        return 'flood';
      case 5:
        return 'storm';
      case 6:
        return 'rescue';
      case 7:
        return 'fire';
      default:
        return 'unknown';
    }
  }

  String _alertTitleFromType(int code) {
    switch (code) {
      case 1:
        return 'Earthquake';
      case 2:
        return 'Tsunami Alert';
      case 3:
        return 'Evacuation';
      case 4:
        return 'Flood';
      case 5:
        return 'Storm';
      case 6:
        return 'Rescue Needed';
      case 7:
        return 'Fire';
      default:
        return 'Alert';
    }
  }

  String _alertPriorityFromType(int code) {
    switch (code) {
      case 2:
      case 1:
        return 'critical';
      case 4:
        return 'high';
      default:
        return 'normal';
    }
  }
}
