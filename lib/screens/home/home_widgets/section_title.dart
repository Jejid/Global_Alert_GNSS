import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class SectionTitle extends StatelessWidget {
  final String titleKey;

  const SectionTitle({super.key, required this.titleKey});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final title = _resolveTitle(loc);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _resolveTitle(AppLocalizations loc) {
    switch (titleKey) {
      case 'recentAlerts':
        return loc.recentAlerts;
      case 'alertMap':
        return loc.alertMap;
      default:
        return titleKey;
    }
  }
}
