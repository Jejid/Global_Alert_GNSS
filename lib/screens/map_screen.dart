import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const initialPosition = CameraPosition(
      target: LatLng(0, 0), // Ubicación inicial (puedes cambiar luego)
      zoom: 2.0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Alertas'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const GoogleMap(
        initialCameraPosition: initialPosition,
        zoomControlsEnabled: true,
        myLocationEnabled: false,
        mapType: MapType.normal,
      ),
    );
  }
}
