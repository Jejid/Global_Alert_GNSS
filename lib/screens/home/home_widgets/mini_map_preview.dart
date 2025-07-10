import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../providers/map_state_provider.dart';
import '../../../../providers/navigation_provider.dart';
import '../../../models/alert_message_model.dart';

class MiniMapPreview extends StatelessWidget {
  final List<Marker> markers;
  final List<AlertMessage> alerts;

  const MiniMapPreview({
    super.key,
    required this.markers,
    required this.alerts,
  });

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
              // ✅ Enviar los mismos alerts que se usaron en el minimapa
              Provider.of<MapStateProvider>(
                context,
                listen: false,
              ).setAlerts(alerts);

              // ✅ Cambiar a la pestaña del mapa (índice 1) usando NavigationProvider
              Provider.of<NavigationProvider>(
                context,
                listen: false,
              ).setIndex(1);
            },
            child: SizedBox(
              height: 200,
              child: IgnorePointer(
                ignoring: true,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(4.236479, -72.708779),
                    initialZoom: 2,
                    interactionOptions: const InteractionOptions(
                      flags: ~InteractiveFlag.all, // Desactiva interacciones
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      tileProvider: NetworkTileProvider(
                        headers: {
                          'User-Agent':
                              'GlobalAlertGNSS/1.0 (jejidnike@hotmail.com)',
                          // usa tu email o web
                          'Referer': 'https://domiyi.co',
                          // opcional pero recomendable
                        },
                      ),
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
