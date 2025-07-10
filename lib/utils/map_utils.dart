import 'package:global_alert_gnss/models/alert_message_model.dart';

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
