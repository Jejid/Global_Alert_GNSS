import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../../../../providers/map_state_provider.dart';
import '../../../../providers/navigation_provider.dart';
import '../../../models/alert_message_model.dart';
import '../../../models/map_entry_source.dart';
import '../../../utils/map_utils.dart';

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
    // Obtener todas las coordenadas de las alertas
    final coords = getAllCoordinates(alerts);

    //No renderizar hasta que haya coordenadas
    if (coords.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("Cargando alertas... 🛰️")),
      );
    }

    // Calcular centro y zoom con base a las coordenadas
    final center = calculateMedianaCenter(coords);
    final zoom = calculateZoomFromAlerts(alerts);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              final mapState = Provider.of<MapStateProvider>(
                context,
                listen: false,
              );
              final nav = Provider.of<NavigationProvider>(
                context,
                listen: false,
              );

              mapState.setAlerts(alerts); // 🛰️ Carga alertas recientes
              mapState.setEntrySource(MapEntrySource.fromMiniMap);
              mapState.triggerCenterOnAlerts();
              nav.setIndex(1); // Cambia a la pestaña del mapa
            },
            child: SizedBox(
              height: 200,
              child: IgnorePointer(
                ignoring: true,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: zoom,
                    interactionOptions: const InteractionOptions(
                      flags: ~InteractiveFlag.all,
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
                          'Referer': 'https://domiyi.co',
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
