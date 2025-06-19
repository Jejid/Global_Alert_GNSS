import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'models/alert_message.dart';
import 'services/alert_service.dart';
import 'screens/alert_detail_screen.dart';
import 'utils/alert_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final systemLocale = PlatformDispatcher.instance.locale.languageCode;

  await initializeDateFormatting(systemLocale, null);
  Intl.defaultLocale = systemLocale;

  runApp(const GlobalAlertApp());
}

class GlobalAlertApp extends StatelessWidget {
  const GlobalAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Alert GNSS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black54,
      ),
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
        backgroundColor: Colors.deepPurple,
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
                            Icon(
                              getAlertIcon(alert.type),
                              color: Colors.white,
                              size: 28,
                            ),
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
                          if(alert.regions!.length > 1)
                            Text(
                            'Region(es): ${alert.regions!.join(', ')}',
                            style: const TextStyle(color: Colors.white70),
                          )else Text(
                              'Region: ${alert.regions!.join("")}',
                              style: const TextStyle(color: Colors.white70)) ,
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
