// lib/services/gnss_stream_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import '../models/alert_message_model.dart';
import '../protocols/globert_medium/globert_message.dart';
import '../utils/alert_format_utils.dart';

class GnssStreamService {
  final Duration interval;
  final StreamController<AlertMessage> _controller =
      StreamController<AlertMessage>.broadcast();
  List<AlertMessage> _alerts = [];

  GnssStreamService({this.interval = const Duration(seconds: 1)});

  Stream<AlertMessage> getAlertStream() => _controller.stream;

  Future<void> init() async {
    _alerts = [];

    // 1) medium examples
    try {
      final medStr = await rootBundle.loadString(
        'assets/alerts_examples_medium.json',
      );
      final medList = jsonDecode(medStr) as List<dynamic>;
      for (final e in medList) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(e as Map);
        final a = parseJsonEntryToAlert(map);
        _alerts.add(a);
        // push initial sample to stream (optional: delay)
        _controller.add(a);
      }
    } catch (e) {
      print('Error loading alerts_examples_medium.json: $e');
    }

    // 2) camf wrapper examples
    try {
      final camfStr = await rootBundle.loadString(
        'assets/alerts_examples_camf.json',
      );
      final camfList = jsonDecode(camfStr) as List<dynamic>;
      for (final e in camfList) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(e as Map);
        // parse and add
        final a = parseJsonEntryToAlert(map);
        _alerts.add(a);
        _controller.add(a);
      }
    } catch (e) {
      print('Error loading alerts_examples_camf.json: $e');
    }

    // 3) legacy examples (optional)
    try {
      final legacy = await rootBundle.loadString('assets/alerts_examples.json');
      final leg = jsonDecode(legacy) as List<dynamic>;
      for (final e in leg) {
        final map = Map<String, dynamic>.from(e as Map);
        final a = parseJsonEntryToAlert(map);
        _alerts.add(a);
        _controller.add(a);
      }
    } catch (_) {}

    // If you want periodic re-emission for simulation, you can start a timer (optional)
    // Timer.periodic(interval, (_) {
    //   for (final a in _alerts) {
    //     _controller.add(a);
    //   }
    // });
  }

  /// Call this when you receive a base64 payload from the platform (or bytes)
  void handleIncomingBase64(String b64, {Map<String, dynamic>? rawWrapper}) {
    try {
      final alert = parseBase64Payload(b64, rawWrapper: rawWrapper);
      _controller.add(alert);
    } catch (e) {
      print('handleIncomingBase64 error: $e');
    }
  }

  /// Call this when you receive raw bytes from the platform (Uint8List)
  void handleIncomingRaw(Uint8List bytes) {
    try {
      // 20 bytes likely medium (Globert); 16 bytes ~ CAMF
      if (bytes.length == 20) {
        try {
          final gm = GlobertMessage.fromBytes(bytes.toList());
          // try to use a toJson-like method if exists
          try {
            final map = (gm as dynamic).toAlertJson() as Map<String, dynamic>;
            final alert = AlertMessage.fromJson(Map<String, dynamic>.from(map));
            _controller.add(alert);
            return;
          } catch (_) {
            // fallback: emit minimal medium-like alert with base64 raw
            final b64 = base64Encode(bytes);
            final fallback = AlertMessage(
              id: 'medium-bytes-${DateTime.now().toUtc().toIso8601String()}',
              type: 'medium',
              title: 'MEDIUM (raw bytes)',
              scope: 'zonal',
              timestamp: DateTime.now().toUtc(),
              message: 'Payload medium de 20 bytes recibido (formato binario).',
              language: 'es',
              source: 'medium',
              rawBase64: b64,
              raw: {
                'raw_bytes_hex': bytes
                    .map((b) => b.toRadixString(16).padLeft(2, '0'))
                    .join(),
              },
              rawBytes: bytes,
            );
            _controller.add(fallback);
            return;
          }
        } catch (e) {
          // If GlobertMessage not present or fails -> fallback
          final b64 = base64Encode(bytes);
          final fallback = AlertMessage(
            id: 'medium-bytes-${DateTime.now().toUtc().toIso8601String()}',
            type: 'medium',
            title: 'MEDIUM (raw bytes)',
            scope: 'zonal',
            timestamp: DateTime.now().toUtc(),
            message: 'Payload medium de 20 bytes recibido (formato binario).',
            language: 'es',
            source: 'medium',
            rawBase64: b64,
            raw: {
              'raw_bytes_hex': bytes
                  .map((b) => b.toRadixString(16).padLeft(2, '0'))
                  .join(),
            },
            rawBytes: bytes,
          );
          _controller.add(fallback);
          return;
        }
      } else {
        // treat as CAMF
        final camfAlert = AlertMessage.fromCamfBytes(bytes);
        _controller.add(camfAlert);
      }
    } catch (e) {
      print('handleIncomingRaw error: $e');
    }
  }
}
