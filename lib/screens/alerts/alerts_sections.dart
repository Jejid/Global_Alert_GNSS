import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/footer_nav_bar.dart';
import '../../l10n/app_localizations.dart';
import '../map/map_screen.dart';
import '../settings_screen.dart';
import '../home/home_screen.dart';
import 'alerts_controller.dart';
import 'alerts_list.dart';

class AlertsSections extends StatelessWidget {
  const AlertsSections({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AlertsController>();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0F14),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  const Icon(Icons.list_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      loc.alertsTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Opacity(
                    opacity: 0,
                    child: Icon(Icons.list_rounded, size: 28),
                  ),
                ],
              ),
            ),

            // Search box
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2233),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: controller.updateSearch,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: loc.searchAlerts,
                    hintStyle: const TextStyle(color: Color(0xFF9ba1bb)),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF9ba1bb)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // List
            Expanded(
              child: AlertsList(alerts: controller.filteredAlerts),
            ),

            // Footer
            FooterNavBar(
              current: NavPage.history,
              onHomeTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              onMapTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => MapScreen(alerts: controller.filteredAlerts),
                ));
              },
              onHistoryTap: () {},
              onSettingsTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
