import 'package:flutter/material.dart';
import '../models/alert_message_model.dart';
import '../services/alert_service.dart';
import '../utils/alert_utils.dart';
import '../screens/alert_detail_screen.dart';
import '../l10n/app_localizations.dart';

class AlertsListScreen extends StatelessWidget {
  const AlertsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.alertsTitle),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<AlertMessage>>(
        future: AlertService.loadAlerts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(loc.loadingError));
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
                                ? '${loc.regions} ${alert.regions!.join(", ")}'
                                : '${loc.region} ${alert.regions!.first}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        if (alert.validUntil != null)
                          Text(
                            '${loc.validUntil} ${formatDate(alert.validUntil!)}',
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
