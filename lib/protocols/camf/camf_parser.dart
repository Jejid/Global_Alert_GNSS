// lib/protocols/globert/camf_parser.dart
import 'dart:math';
import 'dart:typed_data';

/// Bit reader MSB-first (primer bit = MSB del primer byte).
class _BitReader {
  final Uint8List bytes;
  int _bitPos = 0; // posición en bits

  _BitReader(this.bytes);

  int readBits(int n) {
    if (n <= 0) return 0;
    int out = 0;
    for (int i = 0; i < n; i++) {
      final byteIndex = _bitPos >> 3; // /8
      final bitIndexInByte = 7 - (_bitPos & 7); // MSB-first
      if (byteIndex >= bytes.length) {
        throw RangeError('read past end of buffer');
      }
      final bit = (bytes[byteIndex] >> bitIndexInByte) & 1;
      out = (out << 1) | bit;
      _bitPos++;
    }
    return out;
  }

  int get positionBits => _bitPos;
}

/// Resultado de la decodificación CAMF
class CamfDecoded {
  final Map<String, dynamic> fields;
  CamfDecoded(this.fields);
}

/// Parser CAMF (asume MSB-first; 122 bits ocupados aproximadamente en 16 bytes)
class CamfParser {
  /// Decodifica bytes (Uint8List). Devuelve un mapa con campos A1..A18 y valores interpretados.
  static CamfDecoded decode(Uint8List bytes) {
    final r = _BitReader(bytes);
    final Map<String, dynamic> map = {};

    // A1 (2 bits) - Message type
    final a1 = r.readBits(2);
    map['A1'] = a1;
    map['A1_msgType'] = _a1ToString(a1);

    // A2 (9 bits) - country / numeric code
    final a2 = r.readBits(9);
    map['A2'] = a2;

    // A3 (5 bits) - provider id
    final a3 = r.readBits(5);
    map['A3'] = a3;

    // A4 (7 bits) - hazard code
    final a4 = r.readBits(7);
    map['A4'] = a4;

    // A5 (2 bits) - severity
    final a5 = r.readBits(2);
    map['A5'] = a5;
    map['A5_severity'] = _severityString(a5);

    // A6 (1 bit) - weekNext flag (0=current week, 1=next week)
    final a6 = r.readBits(1);
    map['A6'] = a6;

    // A7 (14 bits) - time-of-week minutes (0..10079 typical)
    final a7 = r.readBits(14);
    map['A7'] = a7; // minutes offset from start of week

    // A8 (2 bits) - duration code
    final a8 = r.readBits(2);
    map['A8'] = a8;
    map['A8_human'] = _durationHuman(a8);

    // A9 (1 bit) - library type
    final a9 = r.readBits(1);
    map['A9'] = a9;

    // A10 (3 bits) - library version
    final a10 = r.readBits(3);
    map['A10'] = a10;

    // A11 (10 bits) - instruction list split (we expose raw and split)
    final a11 = r.readBits(10);
    map['A11'] = a11;
    map['A11_listA'] = (a11 >> 5) & 0x1F;
    map['A11_listB'] = a11 & 0x1F;

    // A12 (16 bits) - latitude index -> map to -90..+90
    final a12 = r.readBits(16);
    map['A12_index'] = a12;
    map['A12_deg'] = -90.0 + a12 * 180.0 / (pow(2, 16) - 1);

    // A13 (17 bits) - longitude index -> map to -180..+180
    final a13 = r.readBits(17);
    map['A13_index'] = a13;
    map['A13_deg'] = -180.0 + a13 * 360.0 / (pow(2, 17) - 1);

    // A14 (5 bits) - semimajor axis code -> meters (log scale)
    final a14 = r.readBits(5);
    map['A14_code'] = a14;
    map['A14_meters'] = _semiAxisMetersFromCode(a14);

    // A15 (5 bits) - semiminor axis
    final a15 = r.readBits(5);
    map['A15_code'] = a15;
    map['A15_meters'] = _semiAxisMetersFromCode(a15);

    // A16 (6 bits) - azimuth
    final a16 = r.readBits(6);
    map['A16_code'] = a16;
    map['A16_deg'] = -90.0 + a16 * (180.0 / pow(2, 6));

    // A17 (2 bits) - subject type for A18 interpretation
    final a17 = r.readBits(2);
    map['A17'] = a17;

    // A18 (15 bits) - specifics (interpretation depends on A17)
    final a18 = r.readBits(15);
    map['A18_code'] = a18;
    map['A18_raw'] = a18;
    map['A18_meaning'] = _a18Interpretation(a17, a18);

    return CamfDecoded(map);
  }

  // ---------- helpers ----------
  static String _a1ToString(int v) {
    switch (v) {
      case 0:
        return 'Test';
      case 1:
        return 'Alert';
      case 2:
        return 'Update';
      case 3:
        return 'AllClear';
      default:
        return 'Unknown';
    }
  }

  static String _severityString(int v) {
    switch (v) {
      case 0:
        return 'Unknown';
      case 1:
        return 'Moderate';
      case 2:
        return 'Severe';
      case 3:
        return 'Extreme';
      default:
        return 'Unknown';
    }
  }

  static String _durationHuman(int v) {
    switch (v) {
      case 0:
        return 'Unknown';
      case 1:
        return '<6h';
      case 2:
        return '6-12h';
      case 3:
        return '12-24h';
      default:
        return 'Unknown';
    }
  }

  static dynamic _a18Interpretation(int a17, int a18) {
    // Mapeo simple; la spec define interpretaciones específicas según A17.
    // Aquí devolvemos un mapa con bits clave para más análisis.
    return {
      'a17': a17,
      'a18_value': a18,
      'a18_bits': a18.toRadixString(2).padLeft(15, '0'),
    };
  }

  // Semiaxis: fórmula logaritmica -> meters for code in 0..31
  static double _semiAxisMetersFromCode(int code) {
    const double Lm0 = 216.2; // approx min (spec)
    const double LM0 = 2500000.0; // max (spec)
    const int N = 32; // 5 bits
    final double log10Lm0 = log(Lm0) / ln10;
    final double log10LM0 = log(LM0) / ln10;
    final double val = pow(
      10.0,
      log10Lm0 + (code / (N - 1)) * (log10LM0 - log10Lm0),
    ).toDouble();
    return val;
  }
}
