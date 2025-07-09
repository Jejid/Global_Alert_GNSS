import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:global_alert_gnss/models/alert_message_model.dart';
import 'package:global_alert_gnss/utils/alert_utils.dart';
import 'map_controller.dart';

class MapWidget extends StatelessWidget {
  final List<AlertMessage> alerts;

  const MapWidget({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    final mapState = Provider.of<MapControllerState>(context);

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
          child: const Icon(Icons.my_location_rounded, color: Colors.blueAccent, size: 30),
        ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        mapController: mapState.animatedMapController.mapController,
        options: MapOptions(
          initialCenter: mapState.userLocation ?? const LatLng(4.236479, -72.708779),
          initialZoom: 2.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}