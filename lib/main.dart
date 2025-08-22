// lib/main.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as provider;

import 'l10n/app_localizations.dart';
import 'models/alert_message_model.dart';
import 'providers/map_state_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/alert_detail/alert_detail_screen.dart';
import 'screens/alerts_list/alerts_controller.dart';
import 'screens/main_screen.dart';
import 'services/gnss_stream_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final systemLocale = PlatformDispatcher.instance.locale.languageCode;
  await initializeDateFormatting(systemLocale, null);
  Intl.defaultLocale = systemLocale;

  // 🚀 Instanciamos el servicio con configuración de emulación
  final gnssService = GnssStreamService(
    mode: EmulationMode.hybrid, // precarga medium y simula CAMF por stream
    emitInterval: const Duration(seconds: 3), // intervalo de simulación
    persistReceived: true, // guarda alertas en memoria local
    replaySavedOnInit: true, // reproduce las guardadas al abrir app
  );

  runApp(
    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => NavigationProvider()),
        provider.ChangeNotifierProvider(create: (_) => MapStateProvider()),

        // Proveedor del servicio GNSS
        provider.Provider<GnssStreamService>.value(value: gnssService),

        // AlertsController se conecta al servicio y llama init()
        provider.ChangeNotifierProvider<AlertsController>(
          create: (_) => AlertsController(gnssService: gnssService)..init(),
        ),
      ],
      child: const GlobalAlertApp(),
    ),
  );
}

class GlobalAlertApp extends StatelessWidget {
  const GlobalAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Globert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black54,
      ),
      supportedLocales: const [Locale('en'), Locale('es')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateRoute: (settings) {
        if (settings.name == '/alert_detail') {
          final alert = settings.arguments as AlertMessage;
          return MaterialPageRoute(
            builder: (_) => AlertDetailScreen(alert: alert),
          );
        }
        return MaterialPageRoute(builder: (_) => const MainScreen());
      },
    );
  }
}
