import 'dart:math';

import 'package:global_alert_gnss/models/alert_message_model.dart';
import 'package:latlong2/latlong.dart';

/// Clave compuesta única para identificar un marcador en el mapa.
/// Incluye la alerta y sus coordenadas específicas.
class AlertMarkerKey {
  final AlertMessage alert;
  final double lat;
  final double lon;

  AlertMarkerKey({required this.alert, required this.lat, required this.lon});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertMarkerKey &&
          alert.id == other.alert.id &&
          lat == other.lat &&
          lon == other.lon;

  @override
  int get hashCode => alert.id.hashCode ^ lat.hashCode ^ lon.hashCode;
}

/// Extrae todas las coordenadas de todas las alertas
List<LatLng> getAllCoordinates(List<AlertMessage> alerts) {
  return alerts
      .expand((alert) => alert.locations ?? [])
      .map((loc) => LatLng(loc.lat, loc.lon))
      .toList();
}

/// Calcula el centro promedio de una lista de coordenadas
LatLng calculateCenter(List<LatLng> coords) {
  if (coords.isEmpty) {
    return const LatLng(4.236479, -72.708779); // fallback
  }

  double minLat = coords.first.latitude;
  double maxLat = coords.first.latitude;
  double minLng = coords.first.longitude;
  double maxLng = coords.first.longitude;

  for (final c in coords) {
    if (c.latitude < minLat) minLat = c.latitude;
    if (c.latitude > maxLat) maxLat = c.latitude;
    if (c.longitude < minLng) minLng = c.longitude;
    if (c.longitude > maxLng) maxLng = c.longitude;
  }

  final centerLat = (minLat + maxLat) / 2;
  final centerLng = (minLng + maxLng) / 2;
  return LatLng(centerLat, centerLng);
}

/// Calcula un nivel de zoom adecuado, usando el radio cuando hay
/// una sola ubicación, o la dispersión si son varias.
double calculateZoomFromAlerts(List<AlertMessage> alerts) {
  final coords = alerts
      .expand((a) => a.locations ?? [])
      .map((loc) => LatLng(loc.lat, loc.lon))
      .toList();

  if (coords.isEmpty) return 5;
  if (coords.length == 1) return 10;

  double minLat = coords.first.latitude;
  double maxLat = coords.first.latitude;
  double minLng = coords.first.longitude;
  double maxLng = coords.first.longitude;

  for (var c in coords) {
    minLat = min(minLat, c.latitude);
    maxLat = max(maxLat, c.latitude);
    minLng = min(minLng, c.longitude);
    maxLng = max(maxLng, c.longitude);
  }

  final latDiff = maxLat - minLat;
  final lngDiff = maxLng - minLng;
  final maxDiff = max(latDiff, lngDiff);

  if (maxDiff <= 0) return 15;
  final rawZoom = (log(360 / maxDiff) / ln2);
  // Restricción entre niveles de zoom razonables
  return rawZoom.clamp(4.0, 15.0);
}
