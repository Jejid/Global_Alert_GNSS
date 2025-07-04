import 'package:flutter/material.dart';
import 'package:global_alert_gnss/l10n/app_localizations.dart';
import 'package:global_alert_gnss/screens/home/home_screen.dart';
import 'package:global_alert_gnss/screens/map/map_screen.dart';
import '../../components/footer_nav_bar.dart';
import '../alerts/alerts_screen.dart';
import 'settings_sections.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0F14),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(child: SettingsSections()),
            FooterNavBar(
              current: NavPage.settings,
              onHomeTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                );
              },
              onMapTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MapScreen(alerts: [])),
                );
              },
              onHistoryTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AlertsListScreen()),
                );
              },
              onSettingsTap: () {}, // ya estás en ajustes
            ),
          ],
        ),
      ),
    );
  }
}
