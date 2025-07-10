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

/// Calcula un nivel de zoom estimado basado en la dispersión
double calculateZoom(List<LatLng> coords) {
  if (coords.length <= 1) return 5;

  double minLat = coords.first.latitude;
  double maxLat = coords.first.latitude;
  double minLng = coords.first.longitude;
  double maxLng = coords.first.longitude;

  for (var coord in coords) {
    minLat = minLat < coord.latitude ? minLat : coord.latitude;
    maxLat = maxLat > coord.latitude ? maxLat : coord.latitude;
    minLng = minLng < coord.longitude ? minLng : coord.longitude;
    maxLng = maxLng > coord.longitude ? maxLng : coord.longitude;
  }

  final latDiff = maxLat - minLat;
  final lngDiff = maxLng - minLng;
  final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

  if (maxDiff < 0.5) return 10;
  if (maxDiff < 1.5) return 8;
  if (maxDiff < 4) return 6;
  if (maxDiff < 10) return 4;
  return 2;
}
