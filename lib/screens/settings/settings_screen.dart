import 'package:flutter/material.dart';
import 'package:global_alert_gnss/l10n/app_localizations.dart';
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
          ],
        ),
      ),
    );
  }
}
