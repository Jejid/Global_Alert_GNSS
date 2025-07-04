import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../l10n/app_localizations.dart';
import '../alert_detail/alert_detail_screen.dart';
import '../../utils/alert_utils.dart';
import 'home_controller.dart';
import 'home_widgets/alert_card.dart';
import 'home_widgets/section_title.dart';
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
          const SectionTitle(titleKey: 'recentAlerts'),
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
          const SectionTitle(titleKey: 'alertMap'),
          MiniMapPreview(markers: controller.recentMarkers, alerts: controller.monthlyAlerts),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
