import 'package:flutter/material.dart';
import 'package:global_alert_gnss/utils/alert_utils.dart';
import 'package:provider/provider.dart';

import '../../models/alert_message_model.dart';
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
    final alertsToUse = widget.specificAlerts ?? mapStateProvider.alerts;

    mapControllerState = MapControllerState(vsync: this);

    // ✅ Desactiva auto-move si viene desde otra pantalla (pasando alertas)
    mapControllerState.disableAutoMove = widget.specificAlerts != null;

    // ✅ Si viene con alertas específicas, mover la cámara a ellas
    if (widget.specificAlerts != null && alertsToUse.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mapControllerState.moveToAlertsArea(alertsToUse);
      });
    } else {
      // Si no viene con alertas específicas, usar ubicación del usuario
      if (mapStateProvider.alerts.isEmpty) {
        AlertUtils.getAllAlerts().then((alerts) {
          mapStateProvider.setAlerts(alerts);
          mapControllerState.getUserLocation();
        });
      } else {
        mapControllerState.getUserLocation();
      }
    }
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
