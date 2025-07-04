import 'package:flutter/material.dart';
import 'package:global_alert_gnss/components/footer_nav_bar.dart';
import 'package:global_alert_gnss/l10n/app_localizations.dart';
import 'map_widget.dart';
import '../../models/alert_message_model.dart';

class MapSections extends StatelessWidget {
  final List<AlertMessage> alerts;
  final VoidCallback onHomeTap;
  final VoidCallback onMapTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onSettingsTap;

  const MapSections({
    super.key,
    required this.alerts,
    required this.onHomeTap,
    required this.onMapTap,
    required this.onHistoryTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0E0F14);
    const textColor = Colors.white;

    final loc = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              const Icon(Icons.map_rounded, color: textColor, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loc.alertMap,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: MapWidget(alerts: alerts),
          ),
        ),
        const SizedBox(height: 10),
        FooterNavBar(
          current: NavPage.map,
          onHomeTap: onHomeTap,
          onMapTap: onMapTap,
          onHistoryTap: onHistoryTap,
          onSettingsTap: onSettingsTap,
        ),
      ],
    );
  }
}
