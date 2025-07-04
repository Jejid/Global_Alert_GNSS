import 'package:flutter/material.dart';
import 'package:global_alert_gnss/l10n/app_localizations.dart';
import 'setting_item.dart';

class SettingsSections extends StatelessWidget {
  const SettingsSections({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        Text(
          loc.settings,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 28),

        const Text("Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        SettingItem(icon: Icons.person_rounded, title: "Profile", subtitle: "View and edit your profile", onTap: () {}),

        const SizedBox(height: 24),
        const Text("App Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        SettingItem(icon: Icons.notifications_none_rounded, title: "Notifications", subtitle: "Customize your notification preferences", onTap: () {}),
        SettingItem(icon: Icons.brightness_6_rounded, title: "Appearance", subtitle: "Adjust the app appearance", onTap: () {}),
        SettingItem(icon: Icons.privacy_tip_outlined, title: "Privacy", subtitle: "Manage your privacy settings", onTap: () {}),
        SettingItem(icon: Icons.help_outline_rounded, title: "Help & Support", subtitle: "Get help and support", onTap: () {}),
      ],
    );
  }
}
