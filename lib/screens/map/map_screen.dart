import 'package:flutter/material.dart';
import 'package:global_alert_gnss/utils/alert_utils.dart';
import 'package:provider/provider.dart';

import '../../models/alert_message_model.dart';
import '../../models/map_entry_source.dart';
import '../../providers/map_state_provider.dart';
import '../../providers/navigation_provider.dart';
import 'map_controller.dart';
import 'map_sections.dart';
import 'user_gps_button.dart';

class MapScreen extends StatefulWidget {
  final List<AlertMessage>?
  specificAlerts; // para recibir alertas desde otras screens
  const MapScreen({super.key, this.specificAlerts});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late MapControllerState mapControllerState;

  @override
  void initState() {
    super.initState();

    final mapStateProvider = context.read<MapStateProvider>();
    final entrySource = mapStateProvider.entrySource;
    final alertsToUse = widget.specificAlerts ?? mapStateProvider.alerts;

    mapControllerState = MapControllerState(vsync: this);

    // Desactiva movimiento automático si se pasa por parámetro
    mapControllerState.disableAutoMove = widget.specificAlerts != null;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ✅ CASO 1: desde otra pantalla con alertas específicas
      if (widget.specificAlerts != null && alertsToUse.isNotEmpty) {
        mapControllerState.moveToAlertsArea(alertsToUse);
        return;
      }

      // ✅ CASO 2: desde el MiniMapa
      if (entrySource == MapEntrySource.fromMiniMap) {
        if (alertsToUse.isNotEmpty) {
          mapControllerState.moveToAlertsArea(alertsToUse);
        }
      }
      // ✅ CASO 3: desde el botón de lista
      else if (entrySource == MapEntrySource.fromAlertsButton) {
        if (alertsToUse.isNotEmpty) {
          mapControllerState.moveToAlertsArea(alertsToUse);
        }
      }
      // ✅ CASO 4: entrada libre desde el footer
      else if (entrySource == MapEntrySource.fromFooter) {
        if (alertsToUse.isEmpty) {
          final allAlerts = await AlertUtils.getAllAlerts();
          mapStateProvider.setAlerts(allAlerts);
        }
        mapControllerState.getUserLocation();
      }

      // 🧹 Limpiar el entry source después de usarlo
      mapStateProvider.setEntrySource(MapEntrySource.unknown);
    });
  }

  @override
  Widget build(BuildContext context) {
    final navIndex = context.watch<NavigationProvider>().currentIndex;

    if (navIndex == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).unfocus();
      });
    }

    final alerts =
        widget.specificAlerts ?? context.watch<MapStateProvider>().alerts;

    final mapState = context.watch<MapStateProvider>();

    if (mapState.shouldCenterOnAlerts) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final alertsToUse = widget.specificAlerts ?? mapState.alerts;
        if (alertsToUse.isNotEmpty) {
          mapControllerState.moveToAlertsArea(alertsToUse);
        }
        mapState.clearCenterFlag(); // 👈 Limpia el flag después de usarlo
      });
    }

    return ChangeNotifierProvider.value(
      value: mapControllerState,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E0F14),
        body: SafeArea(
          child: Stack(
            children: [
              MapSections(
                alerts: alerts,
                allAlerts: context.read<MapStateProvider>().alerts,
                onHomeTap: () {},
                onMapTap: () {},
                onHistoryTap: () {},
                onSettingsTap: () {},

                // 👇 Esta es la clave
                onClose: () {
                  if (widget.specificAlerts != null) {
                    Navigator.of(context).pop(); // Cierra pantalla completa
                  } else {
                    context
                        .read<NavigationProvider>()
                        .goBack(); // volvemos a la anterior pestaña del footer
                  }
                },
              ),
              const UserGpsButton(),
              Positioned(
                right: 18,
                bottom: 80, // un poco encima del GPS
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoomIn',
                      backgroundColor: Colors.black54,
                      onPressed: () {
                        final map = mapControllerState
                            .animatedMapController
                            .mapController;
                        map.move(map.camera.center, map.camera.zoom + 1);
                      },
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                    const SizedBox(height: 1),
                    FloatingActionButton.small(
                      heroTag: 'zoomOut',
                      backgroundColor: Colors.black54,
                      onPressed: () {
                        final map = mapControllerState
                            .animatedMapController
                            .mapController;
                        map.move(map.camera.center, map.camera.zoom - 1);
                      },
                      child: const Icon(Icons.remove, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
