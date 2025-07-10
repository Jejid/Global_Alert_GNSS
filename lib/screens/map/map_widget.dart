import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:global_alert_gnss/models/alert_message_model.dart';
import 'package:global_alert_gnss/utils/alert_utils.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../utils/map_utils.dart';
import 'map_controller.dart';

class MapWidget extends StatelessWidget {
  final List<AlertMessage> alerts;

  const MapWidget({super.key, required this.alerts});

  LatLng getInitialCenter({
    required List<AlertMessage> alerts,
    required LatLng? userLocation,
    required bool isSpecificAlert,
  }) {
    if (alerts.isNotEmpty && isSpecificAlert) {
      final firstAlert = alerts.first;
      if (firstAlert.locations != null && firstAlert.locations!.isNotEmpty) {
        final loc = firstAlert.locations!.first;
        return LatLng(loc.lat, loc.lon);
      }
    }
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
              key: ValueKey(
                AlertMarkerKey(alert: alert, lat: loc.lat, lon: loc.lon),
              ),
              width: 50,
              height: 50,
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
          onTap: (_, __) => mapState.popupController.hideAllPopups(),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            tileProvider: NetworkTileProvider(
              headers: {
                'User-Agent': 'GlobalAlertGNSS/1.0 (jejidnike@hotmail.com)',
                'Referer': 'https://domiyi.co',
              },
            ),
          ),
          PopupMarkerLayer(
            options: PopupMarkerLayerOptions(
              markers: markers,
              popupController: mapState.popupController,
              markerCenterAnimation: const MarkerCenterAnimation(),
              markerTapBehavior: MarkerTapBehavior.togglePopupAndHideRest(),
              popupDisplayOptions: PopupDisplayOptions(
                builder: (context, marker) {
                  final key = marker.key;
                  if (key is ValueKey<AlertMarkerKey>) {
                    final data = key.value;

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed('/alert_detail', arguments: data.alert);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          data.alert.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
