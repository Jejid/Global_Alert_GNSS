import 'package:flutter/material.dart';
import 'package:global_alert_gnss/screens/alerts/alerts_screen.dart';
import 'package:global_alert_gnss/screens/map/map_screen.dart';
import 'package:global_alert_gnss/screens/settings/settings_screen.dart';
import 'package:global_alert_gnss/l10n/app_localizations.dart';

import 'home_controller.dart';
import 'home_sections.dart';
import '../../components/footer_nav_bar.dart';

//estructura principal
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final HomeController _controller;


  @override
  void initState() {
    super.initState();
    _controller = HomeController(vsync: this);
    _controller.init().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0F14),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FadeTransition(
                opacity: _controller.fadeIn,
                child: HomeSections(controller: _controller),
              ),
            ),
            FooterNavBar(
              current: NavPage.home,
              onHomeTap: () {},
              onMapTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => MapScreen(alerts: _controller.monthlyAlerts),
                ));
              },
              onHistoryTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const AlertsListScreen(),
                ));
              },
              onSettingsTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
