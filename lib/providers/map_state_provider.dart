import 'package:flutter/material.dart';
import '../models/alert_message_model.dart';

class MapStateProvider with ChangeNotifier {
  List<AlertMessage> _alerts = [];

  List<AlertMessage> get alerts => _alerts;

  void setAlerts(List<AlertMessage> newAlerts) {
    _alerts = newAlerts;
    notifyListeners();
  }

  void clearAlerts() {
    _alerts = [];
    notifyListeners();
  }
}

