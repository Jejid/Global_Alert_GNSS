// lib/services/gnss_stream_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/alert_message_model.dart';

enum EmulationMode {
  preloadAll, // carga all desde JSON y emite inmediatamente
  streamOnly, // no carga nada; emite por timer (simulación)
  hybrid, // precarga medium, emite camf por timer
}

class GnssStreamService {
  final Duration emitInterval;
  final EmulationMode mode;
  final bool persistReceived; // si true guarda en SharedPreferences
  final bool replaySavedOnInit; // si true carga persistidos antes de emular

  final StreamController<AlertMessage> _controller =
      StreamController<AlertMessage>.broadcast();

  final List<AlertMessage> _alerts = []; // historial en memoria (persistible)
  final List<Map<String, dynamic>> _mediumJsonQueue = [];
  final List<Map<String, dynamic>> _camfJsonQueue = [];

  Timer? _emitterTimer;
  int _streamIndex = 0;
  SharedPreferences? _prefs;

  static const _prefsKey = 'gnss_saved_alerts_v1';

  GnssStreamService({
    this.emitInterval = const Duration(seconds: 2),
    this.mode = EmulationMode.hybrid,
    this.persistReceived = false,
    this.replaySavedOnInit = true,
  });

  Stream<AlertMessage> getAlertStream() => _controller.stream;

  /// Devuelve copia de todas las alertas (incluye las precargadas)
  List<AlertMessage> getAllAlerts() => List.unmodifiable(_alerts);

  Future<void> init() async {
    // init prefs si persistencia activada
    if (persistReceived) {
      _prefs = await SharedPreferences.getInstance();
    }

    // cargar assets JSON en memoria (no aún convertidos a AlertMessage)
    await _loadAssetsToQueues();

    // si queremos reproducir guardadas antes de emular
    if (persistReceived && replaySavedOnInit) {
      await _replaySavedAlerts();
    }

    switch (mode) {
      case EmulationMode.preloadAll:
        _emitAllPreloaded();
        break;
      case EmulationMode.streamOnly:
        _startEmitterTimer();
        break;
      case EmulationMode.hybrid:
        _emitMediumPreloaded();
        _startEmitterTimer(); // emitirá CAMF por intervalos
        break;
    }
  }

  Future<void> _loadAssetsToQueues() async {
    // medium
    try {
      final medStr = await rootBundle.loadString(
        'assets/alerts_examples_medium.json',
      );
      final medList = jsonDecode(medStr) as List<dynamic>;
      _mediumJsonQueue.clear();
      for (final e in medList) {
        _mediumJsonQueue.add(Map<String, dynamic>.from(e as Map));
      }
    } catch (e) {
      // ignore if missing
    }

    // camf
    try {
      final camfStr = await rootBundle.loadString(
        'assets/alerts_examples_camf.json',
      );
      final camfList = jsonDecode(camfStr) as List<dynamic>;
      _camfJsonQueue.clear();
      for (final e in camfList) {
        _camfJsonQueue.add(Map<String, dynamic>.from(e as Map));
      }
    } catch (e) {
      // ignore if missing
    }
  }

  void _emitAllPreloaded() {
    // Convertir medium y camf a AlertMessage y emitir inmediatamente
    for (final m in _mediumJsonQueue) {
      final alert = AlertMessage.fromJson(m);
      _publishAlert(alert);
      _alerts.add(alert);
    }
    for (final c in _camfJsonQueue) {
      final alert = AlertMessage.fromJson(c);
      _publishAlert(alert);
      _alerts.add(alert);
    }
  }

  void _emitMediumPreloaded() {
    for (final m in _mediumJsonQueue) {
      final alert = AlertMessage.fromJson(m);
      _publishAlert(alert);
      _alerts.add(alert);
    }
  }

  void _startEmitterTimer() {
    _emitterTimer?.cancel();
    // build a combined queue for streaming (simple interleave: camf, medium, camf...)
    final combined = <Map<String, dynamic>>[];
    final maxLen = _camfJsonQueue.length;
    if (maxLen == 0) {
      // fallback: stream medium if camf missing
      combined.addAll(_mediumJsonQueue);
    } else {
      combined.addAll(_camfJsonQueue);
    }

    if (combined.isEmpty) return;

    _streamIndex = 0;
    _emitterTimer = Timer.periodic(emitInterval, (_) {
      if (combined.isEmpty) return;
      final entry = combined[_streamIndex % combined.length];
      final alert = AlertMessage.fromJson(entry);
      _publishAlert(alert);
      _alerts.add(alert);
      _streamIndex++;
    });
  }

  /// Método para publicar alertas en el Stream y opcionalmente persistirlas.
  void _publishAlert(AlertMessage alert) {
    _controller.add(alert);
    if (persistReceived) {
      _saveAlertToPrefs(alert);
    }
  }

  /// Permite enviar un payload base64 (ej: desde la plataforma).
  /// Se intenta detectarlo como CAMF o MEDIUM por heurística:
  /// si decodifica a 20 bytes -> medium fallback; sino -> camf bytes.
  void handleIncomingBase64(String b64, {Map<String, dynamic>? rawWrapper}) {
    try {
      final bytes = base64Decode(b64);
      if (bytes.length == 20) {
        // medium: convertimos el JSON si tienes uno, si no creamos fallback
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
          rawBytes: Uint8List.fromList(bytes),
        );
        _publishAlert(fallback);
        _alerts.add(fallback);
      } else {
        // CAMF
        final alert = AlertMessage.fromCamfBytes(
          Uint8List.fromList(bytes),
          rawWrapper: rawWrapper,
        );
        _publishAlert(alert);
        _alerts.add(alert);
      }
    } catch (e, st) {
      // ignore/print during development
      // debugPrint('handleIncomingBase64 error: $e $st');
    }
  }

  /// Recibir bytes crudos desde plataforma/hardware
  void handleIncomingRaw(Uint8List bytes) {
    try {
      if (bytes.length == 20) {
        handleIncomingBase64(base64Encode(bytes));
      } else {
        final alert = AlertMessage.fromCamfBytes(bytes);
        _publishAlert(alert);
        _alerts.add(alert);
      }
    } catch (e) {
      // debug
    }
  }

  /// Persistir alertas en SharedPreferences (guarda solo el raw JSON si existe,
  /// o crea un wrapper con rawBase64)
  Future<void> _saveAlertToPrefs(AlertMessage alert) async {
    if (_prefs == null) return;
    final entries = _prefs!.getStringList(_prefsKey) ?? <String>[];
    final mapToSave =
        alert.raw ??
        {
          'id': alert.id,
          'type': alert.type,
          'title': alert.title,
          'timestamp': alert.timestamp.toIso8601String(),
          'message': alert.message,
          'rawBase64': alert.rawBase64,
        };
    entries.add(jsonEncode(mapToSave));
    await _prefs!.setStringList(_prefsKey, entries);
  }

  /// Carga las alertas persistidas y las publica en el stream (una sola vez al init)
  Future<void> _replaySavedAlerts() async {
    if (_prefs == null) return;
    final entries = _prefs!.getStringList(_prefsKey) ?? <String>[];
    for (final s in entries) {
      try {
        final Map<String, dynamic> m = jsonDecode(s) as Map<String, dynamic>;
        final alert = AlertMessage.fromJson(m);
        _publishAlert(alert);
        _alerts.add(alert);
      } catch (_) {}
    }
  }

  /// obtener lista no modificable de alertas en memoria
  List<AlertMessage> getSavedAlertsSnapshot() => List.unmodifiable(_alerts);

  void dispose() {
    _emitterTimer?.cancel();
    _controller.close();
  }
}
