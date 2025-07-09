import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapControllerState with ChangeNotifier {
  final AnimatedMapController animatedMapController;
  LatLng? _userLocation;
  bool disableAutoMove = false;

  LatLng? get userLocation => _userLocation;

  MapControllerState({required TickerProvider vsync})
    : animatedMapController = AnimatedMapController(vsync: vsync);

  Future<void> getUserLocation({bool animate = true}) async {
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

    // ✅ Solo mover el mapa si se pide explícitamente
    if (animate && _userLocation != null) {
      animatedMapController.animateTo(
        dest: _userLocation!,
        zoom: 3.2,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    }

    notifyListeners();
  }
}
