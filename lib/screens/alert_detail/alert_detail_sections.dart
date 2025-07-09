import 'package:flutter/material.dart';
import '../../models/alert_message_model.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/alert_utils.dart';
import '../map/map_screen.dart';
import 'alert_detail_card.dart';
import 'alert_detail_header.dart';

class AlertDetailSections extends StatelessWidget {
  final AlertMessage alert;

  const AlertDetailSections({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final color = AlertUtils.getAlertColor(alert.type);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AlertDetailHeader(alert: alert),
            const SizedBox(height: 28),

            // Mensaje
            Text(loc.message,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(alert.message,
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4)),
            const SizedBox(height: 28),

            // Botón de ver en mapa
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MapScreen()),
                  );
                },
                icon: const Icon(Icons.map_rounded, size: 20),
                label: Text(loc.lookInMap),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 3,
                  shadowColor: color.withOpacity(0.4),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Información adicional
            Text(loc.alertInformation,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            AlertDetailCard(label: loc.regions, value: alert.regions?.join(', ') ?? 'N/A'),
            AlertDetailCard(label: loc.timestamp, value: AlertUtils.formatDate(alert.timestamp)),
            AlertDetailCard(label: loc.alertPriority, value: alert.priority ?? 'N/A'),
            AlertDetailCard(label: loc.source, value: alert.source ?? 'N/A'),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
