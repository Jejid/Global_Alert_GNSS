import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Enum para indicar la pantalla actual
enum NavPage { home, map, history, settings }

class FooterNavBar extends StatelessWidget {
  final NavPage current;
  final VoidCallback onHomeTap;
  final VoidCallback onMapTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onSettingsTap;

  const FooterNavBar({
    super.key,
    required this.current,
    required this.onHomeTap,
    required this.onMapTap,
    required this.onHistoryTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      color: const Color(0xFF14161F),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFooterButton(
            icon: Icons.home_rounded,
            label: loc.home,
            isActive: current == NavPage.home,
            onTap: onHomeTap,
          ),
          _buildFooterButton(
            icon: Icons.map_rounded,
            label: loc.alertMap,
            isActive: current == NavPage.map,
            onTap: onMapTap,
          ),
          _buildFooterButton(
            icon: Icons.history_rounded,
            label: loc.history,
            isActive: current == NavPage.history,
            onTap: onHistoryTap,
          ),
          _buildFooterButton(
            icon: Icons.settings_rounded,
            label: loc.settings,
            isActive: current == NavPage.settings,
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton({
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
