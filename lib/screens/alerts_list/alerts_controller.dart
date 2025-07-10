import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/alert_message_model.dart';
import '../../services/gnss_stream_service.dart';

class AlertsController extends ChangeNotifier {
  final GnssStreamService gnssService;
  final List<AlertMessage> _alerts = [];
  List<AlertMessage> _filteredAlerts = [];
  String _searchQuery = '';
  StreamSubscription<AlertMessage>? _subscription;

  AlertsController({required this.gnssService});

  List<AlertMessage> get filteredAlerts => _filteredAlerts;

  Future<void> init() async {
    await gnssService.init();
    _subscription = gnssService.getAlertStream().listen((alert) {
      _alerts.add(alert);
      _applySearch(_searchQuery);
      notifyListeners();
    });
  }

  void _applySearch(String query) {
    _searchQuery = query.trim().toLowerCase();
    _filteredAlerts = _searchQuery.isEmpty
        ? List.from(_alerts)
        : _alerts.where((alert) {
      final title = alert.title.toLowerCase();
      final regions = alert.regions?.join(', ').toLowerCase() ?? '';
      return title.contains(_searchQuery) || regions.contains(_searchQuery);
    }).toList();
  }

  void updateSearch(String query) {
    _applySearch(query);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
