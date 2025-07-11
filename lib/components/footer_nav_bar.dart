import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/map_entry_source.dart';
import '../providers/map_state_provider.dart';
import '../providers/navigation_provider.dart';

class FooterNavBar extends StatelessWidget {
  const FooterNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final currentIndex = context.watch<NavigationProvider>().currentIndex;
    final provider = context.read<NavigationProvider>();

    return Container(
      color: const Color(0xFF14161F),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFooterButton(
            icon: Icons.home_rounded,
            label: loc.home,
            isActive: currentIndex == 0,
            onTap: () {
              FocusScope.of(context).unfocus();
              provider.setIndex(0);
            },
          ),
          _buildFooterButton(
            icon: Icons.map_rounded,
            label: loc.alertMap,
            isActive: currentIndex == 1,
            onTap: () {
              FocusScope.of(context).unfocus();
              final mapState = context.read<MapStateProvider>();
              mapState.setEntrySource(MapEntrySource.fromFooter);
              provider.setIndex(1);
            },
          ),
          _buildFooterButton(
            icon: Icons.history_rounded,
            label: loc.history,
            isActive: currentIndex == 2,
            onTap: () {
              FocusScope.of(context).unfocus();
              provider.setIndex(2);
            },
          ),
          _buildFooterButton(
            icon: Icons.settings_rounded,
            label: loc.settings,
            isActive: currentIndex == 3,
            onTap: () {
              FocusScope.of(context).unfocus();
              provider.setIndex(3);
            },
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
