import 'package:flutter/material.dart';
import 'package:global_alert_gnss/models/alert_message_model.dart';
import 'package:global_alert_gnss/services/alert_service.dart';
import 'package:global_alert_gnss/screens/alert_detail_screen.dart';
import 'package:global_alert_gnss/utils/alert_utils.dart';

class AlertsListScreen extends StatelessWidget {
  const AlertsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Localizations.localeOf(context).languageCode == 'es' ? 'Alertas' : 'Alerts',
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<AlertMessage>>(
        future: AlertService.loadAlerts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar alertas'));
          }

          final alerts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: alerts.length,
            itemBuilder: (context, i) {
              final alert = alerts[i];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlertDetailScreen(alert: alert),
                    ),
                  );
                },
                child: Card(
                  color: getAlertColor(alert.type),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(getAlertIcon(alert.type), color: Colors.white, size: 28),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                alert.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          alert.message,
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        if (alert.regions != null && alert.regions!.isNotEmpty)
                          Text(
                            alert.regions!.length > 1
                                ? 'Regiones: ${alert.regions!.join(", ")}'
                                : 'Región: ${alert.regions!.first}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        if (alert.validUntil != null)
                          Text(
                            'Válido hasta: ${formatDate(alert.validUntil!)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
