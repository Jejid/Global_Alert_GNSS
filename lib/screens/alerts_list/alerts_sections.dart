import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/map_state_provider.dart';
import '../../providers/navigation_provider.dart';
import 'alerts_controller.dart';
import 'alerts_list.dart';

class AlertsSections extends StatefulWidget {
  const AlertsSections({super.key});

  @override
  State<AlertsSections> createState() => _AlertsSectionsState();
}

class _AlertsSectionsState extends State<AlertsSections> {
  int? _lastIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final navProvider = context.watch<NavigationProvider>();
    final mapProvider = context.read<MapStateProvider>();
    final controller = context.read<AlertsController>();

    final currentIndex = navProvider.currentIndex;

    if (_lastIndex != currentIndex) {
      if (currentIndex == 1) {
        mapProvider.setAlerts(controller.filteredAlerts);
      }
      _lastIndex = currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AlertsController>();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0F14),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  const Icon(Icons.list_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      loc.alertsTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Opacity(
                    opacity: 0,
                    child: Icon(Icons.list_rounded, size: 28),
                  ),
                ],
              ),
            ),

            // Search box
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2233),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: controller.updateSearch,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: loc.searchAlerts,
                    hintStyle: const TextStyle(color: Color(0xFF9ba1bb)),
                    border: InputBorder.none,
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 8),
                        const Icon(Icons.search, color: Color(0xFF9ba1bb)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            final controller = context.read<AlertsController>();
                            final nav = context.read<NavigationProvider>();
                            final mapState = context.read<MapStateProvider>();

                            final filtered = controller.filteredAlerts;

                            // ✅ Cargar las alertas filtradas o todas
                            mapState.setAlerts(filtered);

                            // ✅ Cambiar la pestaña al mapa
                            nav.setIndex(1);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C3244),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.map,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // List
            Expanded(child: AlertsList(alerts: controller.filteredAlerts)),
          ],
        ),
      ),
    );
  }
}
