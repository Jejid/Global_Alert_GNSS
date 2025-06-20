import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/alert_message_model.dart';
import '../utils/alert_utils.dart';

class MapScreen extends StatelessWidget {
  final List<AlertMessage> alerts;

  const MapScreen({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[];
    for (final alert in alerts) {
      final color = AlertUtils.getAlertColor(alert.type);
      for (final loc in alert.locations ?? []) {
        markers.add(
          Marker(
            point: LatLng(loc.lat, loc.lon),
            width: 40,
            height: 40,
            child: Icon(
              Icons.location_on,
              color: color,
              size: 32,
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Alertas'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FlutterMap(
        options: MapOptions(
          center: markers.isNotEmpty ? markers.first.point : LatLng(4.236479, -72.708779),
          zoom: 3.5,
          interactiveFlags: InteractiveFlag.all,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.global_alert_gnss',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
