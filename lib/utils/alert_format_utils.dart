import 'dart:convert';
import 'dart:typed_data';

import '../models/alert_message_model.dart';
import '../protocols/globert_medium/globert_message.dart';

class AlertFormatDetector {
  static String detectFromJson(Map<String, dynamic> j) {
    if (j.containsKey('raw_gnss')) return 'camf';
    if (j.containsKey('alertType') || j.containsKey('latitude_deg'))
      return 'medium';
    if (j.containsKey('type') && j.containsKey('locations')) return 'legacy';
    return 'unknown';
  }
}

/// Try to parse an arbitrary JSON entry (camf wrapper or medium)
AlertMessage parseJsonEntryToAlert(Map<String, dynamic> entry) {
  final f = AlertFormatDetector.detectFromJson(entry);
  if (f == 'camf') {
    return AlertMessage.fromCamfJson(entry);
  } else if (f == 'medium') {
    return AlertMessage.fromMediumJson(entry);
  } else {
    return AlertMessage.fromJson(entry);
  }
}

/// Parse base64 payload bytes: decide CAMF vs MEDIUM by length heuristics:
AlertMessage parseBase64Payload(
  String b64, {
  Map<String, dynamic>? rawWrapper,
}) {
  final bytes = base64Decode(b64);
  // MEDIUM in your examples -> 20 bytes; CAMF -> 16 bytes (122 bits used).
  if (bytes.length == 20) {
    // Try to use GlobertMessage if available; else create minimal medium alert
    try {
      final gm = GlobertMessage.fromBytes(
        bytes.toList(),
      ); // require globert_message.dart in repo
      // if GlobertMessage has toAlertJson or similar, use it; else fallback to medium json mapping.
      if (gm != null) {
        try {
          if (gm is dynamic && gm.toAlertJson != null) {
            final Map<String, dynamic> alertJson =
                gm.toAlertJson() as Map<String, dynamic>;
            return AlertMessage.fromJson(alertJson);
          }
        } catch (_) {
          // fallback
        }
      }
    } catch (_) {
      // ignore, fallback to minimal medium alert
    }

    // fallback minimal alert for medium bytes
    return AlertMessage(
      id: 'medium-bytes-${DateTime.now().toUtc().toIso8601String()}',
      type: 'medium',
      title: 'MEDIUM payload (raw)',
      scope: 'zonal',
      timestamp: DateTime.now().toUtc(),
      message: 'MEDIUM payload (raw bytes) preserved',
      language: 'es',
      source: 'medium',
      rawBase64: b64,
      raw:
          rawWrapper ??
          {
            'raw_bytes_hex': bytes
                .map((b) => b.toRadixString(16).padLeft(2, '0'))
                .join(),
          },
      rawBytes: bytes,
    );
  } else {
    // treat as CAMF
    return AlertMessage.fromCamfBytes(
      Uint8List.fromList(bytes),
      rawWrapper: rawWrapper,
    );
  }
}
