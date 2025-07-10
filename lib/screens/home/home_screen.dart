import 'package:flutter/material.dart';
import 'package:global_alert_gnss/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/navigation_provider.dart';
import 'home_controller.dart';
import 'home_sections.dart';

//estructura principal
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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
    final navIndex = context.watch<NavigationProvider>().currentIndex;

    if (navIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).unfocus();
      });
    }

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
          ],
        ),
      ),
    );
  }
}
