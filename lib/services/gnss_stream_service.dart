import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/alert_message_model.dart';

class GnssStreamService {
  final Duration interval;
  List<AlertMessage>? _alerts;
  int _currentIndex = 0;

  GnssStreamService({this.interval = const Duration(seconds: 5)});

  /// Inicializa cargando las alertas desde archivo local
  Future<void> init() async {
    final String jsonStr = await rootBundle.loadString('assets/alerts_examples.json');
    final List<dynamic> data = jsonDecode(jsonStr);
    _alerts = data.map((e) => AlertMessage.fromJson(e)).toList();
  }

  /// Devuelve un stream que emite alertas cada cierto tiempo
  Stream<AlertMessage> getAlertStream() async* {
    if (_alerts == null) {
      await init();
    }

    while (_currentIndex < _alerts!.length) {
      yield _alerts![_currentIndex];
      _currentIndex++;
      await Future.delayed(interval);
    }
  }

  /// Reinicia el índice para simular de nuevo
  void reset() {
    _currentIndex = 0;
  }
}
