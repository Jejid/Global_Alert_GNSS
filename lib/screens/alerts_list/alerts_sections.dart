import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/map_entry_source.dart';
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
        final source = mapProvider.entrySource;

        if (source == MapEntrySource.unknown ||
            source == MapEntrySource.fromFooter) {
          // Si se accede desde el footer sin fuente específica,
          // no actualizamos las alertas. Se usan las que ya tenga el MapState.
        } else {
          // En caso de fuentes conocidas (como desde botón o mini mapa),
          // las alertas ya se setearon antes de cambiar de pestaña.
        }

        // Luego de mostrar el mapa, podemos resetear el entrySource a unknown
        mapProvider.setEntrySource(MapEntrySource.unknown);
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
                  autofocus: false,
                  onChanged: controller.updateSearch,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: loc.searchAlerts,
                    hintStyle: const TextStyle(color: Color(0xFF9ba1bb)),
                    border: InputBorder.none,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 12, right: 8),
                      child: Icon(Icons.search, color: Color(0xFF9ba1bb)),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          final controller = context.read<AlertsController>();
                          final nav = context.read<NavigationProvider>();
                          final mapState = context.read<MapStateProvider>();

                          final filtered = controller.filteredAlerts;

                          // ✅ Indicar que se entra al mapa desde el botón de la lista de alertas
                          mapState.setEntrySource(
                            MapEntrySource.fromAlertsButton,
                          );

                          // ✅ Cargar las alertas filtradas
                          mapState.setAlerts(filtered);

                          // ✅ Esperamos al siguiente frame, y luego movemos el mapa
                          mapState.triggerCenterOnAlerts();

                          // ✅ Cambiar la pestaña al mapa
                          nav.setIndex(1);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C3244),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.map,
                            color: Colors.white,
                            size: 22, // 🔍 Más grande
                          ),
                        ),
                      ),
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
