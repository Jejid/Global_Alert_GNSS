import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class FooterNavBar extends StatelessWidget {
  final String currentScreen; // "home", "map", "history", "settings"
  final void Function(String) onNavigate;

  const FooterNavBar({super.key, required this.currentScreen, required this.onNavigate});

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
            isActive: currentScreen == "home",
            onTap: () => onNavigate("home"),
          ),
          _buildFooterButton(
            icon: Icons.map_rounded,
            label: loc.alertMap,
            isActive: currentScreen == "map",
            onTap: () => onNavigate("map"),
          ),
          _buildFooterButton(
            icon: Icons.history_rounded,
            label: loc.history,
            isActive: currentScreen == "history",
            onTap: () => onNavigate("history"),
          ),
          _buildFooterButton(
            icon: Icons.settings_rounded,
            label: loc.settings,
            isActive: currentScreen == "settings",
            onTap: () => onNavigate("settings"),
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
