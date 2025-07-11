import 'package:flutter/material.dart';

import '../models/alert_message_model.dart';
import '../models/map_entry_source.dart';

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

  bool _shouldCenterOnAlerts = false;

  bool get shouldCenterOnAlerts => _shouldCenterOnAlerts;

  void triggerCenterOnAlerts() {
    _shouldCenterOnAlerts = true;
    notifyListeners();
  }

  void clearCenterFlag() {
    _shouldCenterOnAlerts = false;
  }

  MapEntrySource _entrySource = MapEntrySource.fromFooter; // 👈 nuevo
  MapEntrySource get entrySource => _entrySource;

  void setEntrySource(MapEntrySource source) {
    _entrySource = source;
  }
}
