import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/alert_message_model.dart';
import '../../utils/alert_utils.dart';

//gestión de alertas y animación
// Este controlador encapsula lógica, animación y datos.
class HomeController with ChangeNotifier {
  late final AnimationController animController;
  late final Animation<double> fadeIn;

  List<AlertMessage> recentAlerts = [];
  List<AlertMessage> monthlyAlerts = [];
  List<Marker> recentMarkers = [];

  HomeController({required TickerProvider vsync}) {
    animController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 800),
    );
    fadeIn = CurvedAnimation(parent: animController, curve: Curves.easeIn);
  }

  Future<void> init() async {
    animController.forward();
    await _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final allAlerts = await AlertUtils.getAllAlerts();

    final recent = <AlertMessage>[];
    final month = <AlertMessage>[];
    final markers = <Marker>[];

    for (final alert in allAlerts) {
      if (alert.timestamp.isAfter(thirtyDaysAgo) &&
          alert.locations != null &&
          alert.locations!.isNotEmpty) {
        month.add(alert);

        if (alert.timestamp.isAfter(threeDaysAgo)) {
          recent.add(alert);
          final color = AlertUtils.getAlertColor(alert.type);
          for (final loc in alert.locations!) {
            markers.add(
              Marker(
                point: LatLng(loc.lat, loc.lon),
                width: 40,
                height: 40,
                child: Icon(Icons.location_on, color: color, size: 32),
              ),
            );
          }
        }
      }
    }

    recentAlerts = recent;
    monthlyAlerts = month;
    recentMarkers = markers;

    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    animController.dispose();
  }
}
