import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../models/alert_message_model.dart';
import '../../utils/map_utils.dart';

class MapControllerState with ChangeNotifier {
  final AnimatedMapController animatedMapController;
  final PopupController popupController = PopupController(); // 👈 nuevo

  LatLng? _userLocation;
  bool disableAutoMove = false;

  LatLng? get userLocation => _userLocation;

  MapControllerState({required TickerProvider vsync})
    : animatedMapController = AnimatedMapController(vsync: vsync);

  Future<void> getUserLocation() async {
    bool shoulAnimate = !disableAutoMove;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    _userLocation = LatLng(position.latitude, position.longitude);

    if (shoulAnimate && _userLocation != null) {
      animatedMapController.animateTo(
        dest: _userLocation!,
        zoom: 4,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    }

    notifyListeners();
  }

  Future<void> centerToUserLocation() async {
    final previous = disableAutoMove;
    disableAutoMove = false;
    await getUserLocation();
    disableAutoMove = previous;
  }

  void moveToAlertsArea(List<AlertMessage> alerts) {
    final coords = getAllCoordinates(alerts);
    final center = calculateMedianaCenter(coords);
    final zoom = calculateZoomFromAlerts(alerts);

    if (coords.isNotEmpty) {
      animatedMapController.animateTo(
        dest: center,
        zoom: zoom,
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    popupController.dispose(); //  liberar
    super.dispose();
  }
}
