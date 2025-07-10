import 'package:flutter/material.dart';
import 'package:global_alert_gnss/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/navigation_provider.dart';
import 'settings_sections.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navIndex = context.watch<NavigationProvider>().currentIndex;

    if (navIndex == 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).unfocus();
      });
    }

    final loc = AppLocalizations.of(
      context,
    )!; //aplicar para internacionalización

    return Scaffold(
      backgroundColor: const Color(0xFF0E0F14),
      body: SafeArea(
        child: Column(children: [const Expanded(child: SettingsSections())]),
      ),
    );
  }
}
