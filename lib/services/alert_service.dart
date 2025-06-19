import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/alert_message_model.dart';

class AlertService {
  /// Carga y parsea el JSON completo de `assets/alerts.json`
  static Future<List<AlertMessage>> loadAlerts() async {
    final String jsonStr = await rootBundle.loadString('assets/alerts_examples.json');
    final List<dynamic> data = jsonDecode(jsonStr);
    return data.map((e) => AlertMessage.fromJson(e)).toList();
  }
}
