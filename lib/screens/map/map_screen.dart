import 'package:flutter/material.dart';
import 'package:global_alert_gnss/utils/alert_utils.dart';
import 'package:provider/provider.dart';

import '../../models/alert_message_model.dart';
import '../../providers/map_state_provider.dart';
import '../../providers/navigation_provider.dart';
import 'fab_gps_button.dart';
import 'map_controller.dart';
import 'map_sections.dart';

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
    if (mapStateProvider.alerts.isEmpty) {
      AlertUtils.getAllAlerts().then((alerts) {
        mapStateProvider.setAlerts(alerts);
      });
    }

    mapControllerState = MapControllerState(vsync: this);

    // ✅ Desactiva el movimiento si viene con alertas específicas
    mapControllerState.disableAutoMove = widget.specificAlerts != null;

    mapControllerState.getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    final alerts =
        widget.specificAlerts ?? context.watch<MapStateProvider>().alerts;

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
              const FabGpsButton(),
            ],
          ),
        ),
      ),
    );
  }
}
