import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../models/alert_message_model.dart';
import '../../map/map_screen.dart';


// el minimapa
class MiniMapPreview extends StatelessWidget {
  final List<Marker> markers;
  final List<AlertMessage> alerts;

  const MiniMapPreview({super.key, required this.markers, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MapScreen(alerts: alerts),
                ),
              );
            },
            child: SizedBox(
              height: 200,
              child: IgnorePointer(
                ignoring: true,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(4.236479, -72.708779),
                    initialZoom: 2,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
