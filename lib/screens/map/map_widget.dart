import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:global_alert_gnss/models/alert_message_model.dart';
import 'package:global_alert_gnss/utils/alert_utils.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'map_controller.dart';

class MapWidget extends StatelessWidget {
  final List<AlertMessage> alerts;

  const MapWidget({super.key, required this.alerts});

  // 🔍 funcion auxiliar para centrar el mapa según la alerta o el usuario
  LatLng getInitialCenter({
    required List<AlertMessage> alerts,
    required LatLng? userLocation,
    required bool isSpecificAlert,
  }) {
    if (alerts.isNotEmpty && isSpecificAlert) {
      // Centrar en la primera ubicación de la primera alerta específica
      final firstAlert = alerts.first;
      if (firstAlert.locations != null && firstAlert.locations!.isNotEmpty) {
        final loc = firstAlert.locations!.first;
        return LatLng(loc.lat, loc.lon);
      }
    }

    // Si no es alerta específica, usar ubicación del usuario o valor por defecto
    return userLocation ?? const LatLng(4.236479, -72.708779);
  }

  @override
  Widget build(BuildContext context) {
    final mapState = Provider.of<MapControllerState>(context);
    final isSpecificAlert = alerts.length == 1;

    final markers = <Marker>[
      for (var alert in alerts)
        if (alert.locations != null)
          for (var loc in alert.locations!)
            Marker(
              width: 40,
              height: 40,
              point: LatLng(loc.lat, loc.lon),
              child: Icon(
                Icons.location_on,
                color: AlertUtils.getAlertColor(alert.type),
                size: 32,
              ),
            ),
      if (mapState.userLocation != null)
        Marker(
          width: 36,
          height: 36,
          point: mapState.userLocation!,
          child: const Icon(
            Icons.my_location_rounded,
            color: Colors.blueAccent,
            size: 30,
          ),
        ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        mapController: mapState.animatedMapController.mapController,
        options: MapOptions(
          initialCenter: getInitialCenter(
            alerts: alerts,
            userLocation: mapState.userLocation,
            isSpecificAlert: isSpecificAlert,
          ),
          initialZoom: 8,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            tileProvider: NetworkTileProvider(
              headers: {
                'User-Agent': 'GlobalAlertGNSS/1.0 (jejidnike@hotmail.com)',
                // usa tu email o web
                'Referer': 'https://domiyi.co',
                // opcional pero recomendable
              },
            ),
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
