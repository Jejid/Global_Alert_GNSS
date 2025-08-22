// lib/models/alert_message_model.dart
import 'dart:convert';
import 'dart:typed_data';

import '../protocols/camf/camf_parser.dart';

class AlertMessage {
  final String id;
  final String type;
  final String title;
  final String scope;
  final DateTime timestamp;
  final String message;
  final List<Location>? locations;
  final String language;
  final String source; // 'medium' | 'camf' | 'legacy'
  final Map<String, dynamic>? raw;
  final String? rawBase64;
  final Uint8List? rawBytes; // decodificado (opcional)

  AlertMessage({
    required this.id,
    required this.type,
    required this.title,
    required this.scope,
    required this.timestamp,
    required this.message,
    this.locations,
    required this.language,
    required this.source,
    this.raw,
    this.rawBase64,
    this.rawBytes,
  });

  /// Fábrica detectora (intenta medium -> camf wrapper -> legacy)
  factory AlertMessage.fromJson(Map<String, dynamic> json) {
    // Detect CAMF wrapper: has raw_gnss
    if (json.containsKey('raw_gnss')) {
      return AlertMessage.fromCamfJson(json);
    }

    // Detect medium example payload (ej: fields 'alertType' o 'latitude_deg')
    if (json.containsKey('alertType') || json.containsKey('latitude_deg')) {
      return AlertMessage.fromMediumJson(json);
    }

    // Fallback legacy (intento de parse flexible)
    final ts = _parseTimestamp(json);
    return AlertMessage(
      id: json['id']?.toString() ?? 'legacy-${ts.toIso8601String()}',
      type: json['type']?.toString() ?? 'legacy',
      title:
          json['title']?.toString() ??
          json['short_text']?.toString() ??
          'Sin título',
      scope: json['scope']?.toString() ?? 'zonal',
      timestamp: ts,
      message:
          json['message']?.toString() ?? json['short_text']?.toString() ?? '',
      locations: null,
      language: json['language']?.toString() ?? 'es',
      source: json['source']?.toString() ?? 'legacy',
      raw: json,
      rawBase64: json['sim_payload_b64']?.toString(),
    );
  }

  /// Construye desde el JSON "medium" (ej: alerts_examples_medium.json)
  factory AlertMessage.fromMediumJson(Map<String, dynamic> json) {
    // referencia epoch (usamos 2025-01-01 como base en tu ejemplo)
    final refEpoch = DateTime.utc(2025, 1, 1);
    DateTime ts;
    if (json['timestamp_minutes'] != null) {
      final mins = (json['timestamp_minutes'] as num).toInt();
      ts = refEpoch.add(Duration(minutes: mins));
    } else if (json['timestamp'] != null) {
      ts = DateTime.parse(json['timestamp']);
    } else {
      ts = DateTime.now().toUtc();
    }

    final List<Location> locs = [];
    if (json.containsKey('latitude_deg') && json.containsKey('longitude_deg')) {
      final lat = (json['latitude_deg'] as num).toDouble();
      final lon = (json['longitude_deg'] as num).toDouble();
      final radius = json['radius_meters'] != null
          ? (json['radius_meters'] as num).toDouble()
          : (json['radius_index'] != null
                ? GlobertRadiusHelper.indexToRadius(
                    json['radius_index'] as int,
                  ).toDouble()
                : 0.0);
      locs.add(Location(lat: lat, lon: lon, radiusMeters: radius));
    }

    return AlertMessage(
      id: json['id']?.toString() ?? 'medium-${ts.toIso8601String()}',
      type: 'medium',
      title: json['short_text']?.toString() ?? 'Alerta',
      scope: 'zonal',
      timestamp: ts,
      message: json['short_text']?.toString() ?? '',
      locations: locs.isEmpty ? null : locs,
      language: 'es',
      source: 'medium',
      raw: json,
      rawBase64: json['sim_payload_b64']?.toString(),
    );
  }

  /// Construye desde el wrapper CAMF JSON (alerts_examples_camf.json)
  factory AlertMessage.fromCamfJson(Map<String, dynamic> json) {
    final rawGnss = (json['raw_gnss'] is Map)
        ? Map<String, dynamic>.from(json['raw_gnss'])
        : null;
    final simB64 = rawGnss != null
        ? rawGnss['sim_payload_b64']?.toString()
        : null;
    if (simB64 != null) {
      try {
        final bytes = base64Decode(simB64);
        return AlertMessage.fromCamfBytes(
          Uint8List.fromList(bytes),
          rawWrapper: json,
        );
      } catch (_) {
        // decode failed: fallback to minimal alert with raw info
        final tsStr = rawGnss != null && rawGnss['timestamp'] != null
            ? rawGnss['timestamp'].toString()
            : null;
        DateTime ts;
        if (tsStr != null) {
          try {
            ts = DateTime.parse(tsStr).toUtc();
          } catch (_) {
            ts = DateTime.now().toUtc();
          }
        } else {
          ts = DateTime.now().toUtc();
        }
        return AlertMessage(
          id: 'camf-${ts.toIso8601String()}',
          type: 'camf',
          title: 'CAMF (no-decodable)',
          scope: 'zonal',
          timestamp: ts,
          message: 'CAMF payload (no pudo decodificarse) - raw preserved',
          locations: null,
          language: 'es',
          source: 'camf',
          raw: json,
          rawBase64: simB64,
        );
      }
    } else {
      // no sim payload -> minimal
      final ts = rawGnss != null && rawGnss['timestamp'] != null
          ? DateTime.tryParse(rawGnss['timestamp'].toString())?.toUtc() ??
                DateTime.now().toUtc()
          : DateTime.now().toUtc();
      return AlertMessage(
        id: 'camf-${ts.toIso8601String()}',
        type: 'camf',
        title: 'CAMF (wrapper)',
        scope: 'zonal',
        timestamp: ts,
        message: 'CAMF wrapper sin sim_payload_b64',
        locations: null,
        language: 'es',
        source: 'camf',
        raw: json,
      );
    }
  }

  /// Construye a partir de bytes CAMF (usa CamfParser.decode)
  /// rawWrapper es opcional (el objeto JSON que venía en alerts_examples_camf.json)
  factory AlertMessage.fromCamfBytes(
    Uint8List bytes, {
    Map<String, dynamic>? rawWrapper,
  }) {
    final parsed = CamfParser.decode(bytes);
    final f = parsed.fields;

    // compute timestamp using A6 (weekNext) + A7 (minutes-of-week)
    DateTime ts = DateTime.now().toUtc();
    try {
      final int weekNext = (f['A6'] is int)
          ? f['A6'] as int
          : int.tryParse(f['A6'].toString()) ?? 0;
      final int minutesOfWeek = (f['A7'] is int)
          ? f['A7'] as int
          : int.tryParse(f['A7'].toString()) ?? 0;

      // Compute start of current ISO week (Monday 00:00 UTC)
      final now = DateTime.now().toUtc();
      final int weekday = now.toUtc().weekday; // 1=Mon..7=Sun
      final weekStart = DateTime.utc(now.year, now.month, now.day)
          .subtract(Duration(days: weekday - 1))
          .toUtc()
          .subtract(
            Duration(
              hours: now.hour,
              minutes: now.minute,
              seconds: now.second,
              milliseconds: now.millisecond,
              microseconds: now.microsecond,
            ),
          ); // normalize to 00:00

      final base = weekNext == 1 ? weekStart.add(Duration(days: 7)) : weekStart;
      ts = base.add(Duration(minutes: minutesOfWeek));
    } catch (_) {
      ts = DateTime.now().toUtc();
    }

    // create id from country/provider/time
    final id =
        'camf-${f['A2'] ?? 'x'}-${f['A3'] ?? 'x'}-${ts.toIso8601String()}';

    // assemble message/title
    final hazardCode = f['A4'] ?? 'unknown';
    final severity = f['A5_severity'] ?? 'unknown';
    final LatLon? loc;
    if (f.containsKey('A12_deg') && f.containsKey('A13_deg')) {
      loc = LatLon(
        (f['A12_deg'] as num).toDouble(),
        (f['A13_deg'] as num).toDouble(),
      );
    } else {
      loc = null;
    }

    final radiusMeters = (f['A14_meters'] is num)
        ? (f['A14_meters'] as num).toDouble()
        : null;
    final secondaryMeters = (f['A15_meters'] is num)
        ? (f['A15_meters'] as num).toDouble()
        : null;

    final title = 'CAMF: hazard ${hazardCode} • ${severity}';
    final sb = StringBuffer();
    sb.writeln(title);
    if (loc != null) {
      sb.writeln(
        'Centro: ${loc.lat.toStringAsFixed(4)}, ${loc.lon.toStringAsFixed(4)}',
      );
    }
    if (radiusMeters != null) {
      sb.writeln('Semi-major rad (m): ${radiusMeters.toStringAsFixed(0)}');
    }
    if (secondaryMeters != null) {
      sb.writeln('Semi-minor rad (m): ${secondaryMeters.toStringAsFixed(0)}');
    }
    sb.writeln('Azimuth (deg): ${f['A16_deg']?.toStringAsFixed(1) ?? 'n/a'}');

    // locations (ellipse-based -> keep center + radiusMeters)
    final locations = <Location>[];
    if (loc != null && radiusMeters != null) {
      locations.add(
        Location(lat: loc.lat, lon: loc.lon, radiusMeters: radiusMeters),
      );
    }

    return AlertMessage(
      id: id,
      type: 'camf',
      title: title,
      scope: 'zonal',
      timestamp: ts,
      message: sb.toString(),
      locations: locations.isEmpty ? null : locations,
      language: 'es',
      source: 'camf',
      raw:
          rawWrapper ??
          {
            'camf_bytes_hex': bytes
                .map((b) => b.toRadixString(16).padLeft(2, '0'))
                .join(),
          },
      rawBase64: base64Encode(bytes),
      rawBytes: bytes,
    );
  }

  // ---------------- helpers ----------------
  static DateTime _parseTimestamp(Map<String, dynamic> json) {
    if (json['timestamp'] != null) {
      try {
        return DateTime.parse(json['timestamp']).toUtc();
      } catch (_) {}
    }
    if (json['ts'] != null) {
      try {
        return DateTime.parse(json['ts']).toUtc();
      } catch (_) {}
    }
    return DateTime.now().toUtc();
  }

  List<String>? get regions {
    try {
      final r = raw?['regions'];
      if (r is List) return List<String>.from(r);
      if (r is String) return [r];
    } catch (_) {}
    // fallback: usar la primera location si existe
    if (locations != null && locations!.isNotEmpty) {
      final loc = locations!.first;
      final lat = loc.lat.toStringAsFixed(4);
      final lon = loc.lon.toStringAsFixed(4);
      final radius = loc.radiusMeters != null
          ? '${loc.radiusMeters!.toStringAsFixed(0)}m'
          : 'N/A';
      return ['$lat, $lon • $radius'];
    }
    return null;
  }

  String? get priority {
    // 1. Buscar prioridad explícita en el JSON crudo
    if (raw?['priority'] != null) {
      return raw!['priority'].toString();
    }

    // 2. Inferir prioridad según tipo de alerta
    switch (type.toLowerCase()) {
      case 'rescue':
      case 'fire':
      case 'earthquake':
      case 'tsunami':
        return 'High';
      case 'storm':
      case 'hurricane':
        return 'Medium';
      case 'missing':
        return 'Low';
      default:
        return null; // si no se sabe
    }
  }
}

// ---------------- Location class ----------------
class Location {
  final double lat;
  final double lon;
  final double? radiusMeters; // null si no hay radio

  Location({required this.lat, required this.lon, this.radiusMeters});

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lon': lon,
    'radius_meters': radiusMeters,
  };

  factory Location.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Location(
      lat: parseDouble(json['lat'] ?? json['latitude'] ?? json['latitude_deg']),
      lon: parseDouble(
        json['lon'] ?? json['longitude'] ?? json['longitude_deg'],
      ),
      radiusMeters: json['radius_meters'] != null
          ? parseDouble(json['radius_meters'])
          : (json['radius_km'] != null
                ? parseDouble(json['radius_km']) * 1000.0
                : null),
    );
  }
}

class LatLon {
  final double lat;
  final double lon;

  LatLon(this.lat, this.lon);
}

/// Helper: tabla index->meters (idéntica a la que usamos antes)
class GlobertRadiusHelper {
  static int indexToRadius(int idx) {
    if (idx == 0) return 0;
    if (1 <= idx && idx <= 5) return idx * 10;
    if (6 <= idx && idx <= 10) {
      const table = {6: 100, 7: 200, 8: 400, 9: 600, 10: 800};
      return table[idx]!;
    }
    if (11 <= idx && idx <= 253) {
      final v = (idx - 10) * 1000;
      return v;
    }
    if (idx == 254) return 500000;
    if (idx == 255) return 1000000;
    return 0;
  }
}
