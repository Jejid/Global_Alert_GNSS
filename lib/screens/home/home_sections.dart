import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../alert_detail/alert_detail_screen.dart';
import 'home_controller.dart';
import 'home_widgets/alert_card.dart';
import 'home_widgets/mini_map_preview.dart';

// Organiza el contenido de la pantalla principal.
// Usa widgets reutilizables:
class HomeSections extends StatelessWidget {
  final HomeController controller;

  const HomeSections({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.public, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    loc.appTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_rounded, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Recent Alerts
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Text(
                  loc.recentAlerts,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Text(
                  '(Last 3 days)',
                  style: TextStyle(color: Color(0xFF9ba1bb), fontSize: 13),
                ),
              ],
            ),
          ),
          controller.recentAlerts.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    loc.noRecentAlerts,
                    style: const TextStyle(color: Color(0xFF9ba1bb)),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.recentAlerts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final alert = controller.recentAlerts[index];
                    return AlertCard(
                      alert: alert,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AlertDetailScreen(alert: alert),
                          ),
                        );
                      },
                    );
                  },
                ),

          // Map Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(
              children: [
                Text(
                  loc.alertMap,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Text(
                  '(Last 3 days)',
                  style: TextStyle(color: Color(0xFF9ba1bb), fontSize: 13),
                ),
              ],
            ),
          ),
          MiniMapPreview(
            markers: controller.recentMarkers,
            alerts: controller
                .recentAlerts, // aquí se pasa la lista de alertas a MiniMapPreview
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
