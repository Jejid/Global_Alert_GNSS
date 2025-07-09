import 'package:flutter/material.dart';
import 'package:global_alert_gnss/components/footer_nav_bar.dart';
import 'package:global_alert_gnss/l10n/app_localizations.dart';

import 'map_widget.dart';
import '../../models/alert_message_model.dart';

class MapSections extends StatelessWidget {
  final List<AlertMessage>? alerts;       // Ahora opcional
  final List<AlertMessage> allAlerts;     // Lista completa para mostrar por defecto

  final VoidCallback onHomeTap;
  final VoidCallback onMapTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onSettingsTap;

  const MapSections({
    super.key,
    this.alerts,
    required this.allAlerts,
    required this.onHomeTap,
    required this.onMapTap,
    required this.onHistoryTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // Si no vienen alertas específicas, mostrar todas
    final List<AlertMessage> alertsToShow = alerts ?? allAlerts;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              const Icon(Icons.map_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loc.alertMap,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () {
                  //cuadrar el cerrar
                },
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: MapWidget(alerts: alertsToShow),
          ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }
}
