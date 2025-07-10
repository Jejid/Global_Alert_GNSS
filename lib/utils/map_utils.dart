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

  final totalLat = coords.fold(0.0, (sum, c) => sum + c.latitude);
  final totalLng = coords.fold(0.0, (sum, c) => sum + c.longitude);
  return LatLng(totalLat / coords.length, totalLng / coords.length);
}

/// Calcula un nivel de zoom adecuado, usando el radio cuando hay
/// una sola ubicación, o la dispersión si son varias.
double calculateZoomFromAlerts(List<AlertMessage> alerts) {
  // Extrae todas las ubicaciones
  final allLocs = alerts.expand((a) => a.locations ?? []).toList();

  // Si no hay ubicaciones, zoom base
  if (allLocs.isEmpty) return 4;

  // Si sólo hay una ubicación, ajusta zoom según el radiusKm
  if (allLocs.length == 1) {
    final r = allLocs.first.radiusKm;
    if (r < 0.5) return 13;
    if (r < 2) return 12;
    if (r < 5) return 10;
    if (r < 20) return 8;
    if (r < 80) return 6;
    return 4; // area muy grande
  }

  // Si son múltiples, calcula bounding box
  double minLat = allLocs.first.lat, maxLat = allLocs.first.lat;
  double minLng = allLocs.first.lon, maxLng = allLocs.first.lon;

  for (var loc in allLocs) {
    if (loc.lat < minLat) minLat = loc.lat;
    if (loc.lat > maxLat) maxLat = loc.lat;
    if (loc.lon < minLng) minLng = loc.lon;
    if (loc.lon > maxLng) maxLng = loc.lon;
  }

  final latDiff = maxLat - minLat;
  final lngDiff = maxLng - minLng;
  final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

  // Umbrales suaves para múltiples puntos
  if (maxDiff < 0.1) return 11;
  if (maxDiff < 0.3) return 10;
  if (maxDiff < 0.7) return 9;
  if (maxDiff < 1.5) return 8;
  if (maxDiff < 3.0) return 7;
  if (maxDiff < 6.0) return 6;
  if (maxDiff < 10.0) return 5;
  return 4;
}
