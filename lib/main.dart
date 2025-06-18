import 'package:flutter/material.dart';
import 'models/alert_message.dart';
import 'services/alert_service.dart';

void main() => runApp(GlobalAlertApp());

class GlobalAlertApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Alert GNSS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: AlertsListScreen(),
    );
  }
}

class AlertsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas GNSS'),
        backgroundColor: Colors.red[700],
      ),
      body: FutureBuilder<List<AlertMessage>>(
        future: AlertService.loadAlerts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint('Error en snapshot: ${snapshot.error}');
            debugPrint('StackTrace: ${snapshot.stackTrace}');
            return Center(child: Text('Error al cargar alertas'));
          }
          final alerts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: alerts.length,
            itemBuilder: (context, i) {
              final alert = alerts[i];
              return Card(
                color: Colors.redAccent.shade200,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        alert.message,
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      if (alert.locations != null)
                        Text(
                          'Coordenadas: ' +
                              alert.locations!
                                  .map((loc) => '${loc.lat.toStringAsFixed(3)}, ${loc.lon.toStringAsFixed(3)}')
                                  .join(' | '),
                          style: const TextStyle(color: Colors.white54),
                        ),
                      if (alert.validUntil != null)
                        Text(
                          'Válido hasta: ${alert.validUntil!.toLocal()}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                    ],
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
