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
    final coords = getAllCoordinates(alerts);
    final center = calculateCenter(coords);
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

              mapState.setAlerts(
                alerts,
              ); // 🛰️ Carga las alertas recientes del minimapa
              mapState.setEntrySource(
                MapEntrySource.fromMiniMap,
              ); //  Muy importante
              mapState.triggerCenterOnAlerts(); //  Centrarse en ellas
              nav.setIndex(1); //  Cambia a la pestaña de mapa
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
