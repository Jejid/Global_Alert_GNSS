import 'package:flutter/material.dart';
import 'package:global_alert_gnss/screens/settings/settings_screen.dart';
import 'package:provider/provider.dart';

import '../components/footer_nav_bar.dart';
import '../providers/navigation_provider.dart';
import 'alerts_list/alerts_screen.dart';
import 'home/home_screen.dart';
import 'map/map_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(), // índice 0
    MapScreen(), // índice 1
    AlertsListScreen(), // índice 2 (puede ser historial)
    SettingsScreen(), // índice 3
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<NavigationProvider>().currentIndex;

    return Scaffold(
      body: Column(
        children: [
          // Pantalla actual
          Expanded(
            child: IndexedStack(index: currentIndex, children: _screens),
          ),

          // Footer personalizado
          const FooterNavBar(),
        ],
      ),
    );
  }
}
