import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'alerts_list_screen.dart';
import 'home_screen.dart';
import 'map_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0E0F14);
    const cardColor = Color(0xFF1A1C24);
    const sectionTitleColor = Colors.white;
    const itemTextColor = Colors.white;
    const subtitleColor = Color(0xFF9ba1bb);
    const iconBackground = Color(0xFF21284a);
    const footerColor = Color(0xFF14161F);

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                children: [
                  Text(
                    loc.settings,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: sectionTitleColor,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: sectionTitleColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingItem(
                    icon: Icons.person_rounded,
                    title: 'Profile',
                    subtitle: 'View and edit your profile',
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'App Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: sectionTitleColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle: 'Customize your notification preferences',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.brightness_6_rounded,
                    title: 'Appearance',
                    subtitle: 'Adjust the app appearance',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy',
                    subtitle: 'Manage your privacy settings',
                    onTap: () {},
                  ),
                  _buildSettingItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'Get help and support',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Container(
              color: footerColor,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFooterButton(
                    context,
                    icon: Icons.home_rounded,
                    label: loc.home,
                    isActive: false,
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (route) => false,
                      );
                    },
                  ),
                  _buildFooterButton(
                    context,
                    icon: Icons.map_rounded,
                    label: loc.alertMap,
                    isActive: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MapScreen(alerts: [])),
                      );
                    },
                  ),
                  _buildFooterButton(
                    context,
                    icon: Icons.history_rounded,
                    label: loc.history,
                    isActive: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AlertsListScreen()),
                      );
                    },
                  ),
                  _buildFooterButton(
                    context,
                    icon: Icons.settings_rounded,
                    label: loc.settings,
                    isActive: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Color(0xFF1A1C24),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(0xFF21284a),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9ba1bb),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required bool isActive,
        required VoidCallback onTap,
      }) {
    const activeColor = Colors.white;
    const inactiveColor = Color(0xFF8e99cc);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? activeColor : inactiveColor, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : inactiveColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
