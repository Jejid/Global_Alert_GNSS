import 'package:flutter/material.dart';
import 'package:global_alert_gnss/utils/alert_utils.dart';
import 'package:provider/provider.dart';

import '../../models/alert_message_model.dart';
import '../../providers/map_state_provider.dart';
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

    // 👇 No mover automáticamente si es alerta específica
    final shouldAnimate = widget.specificAlerts == null;
    mapControllerState.getUserLocation(animate: shouldAnimate);
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
                onHomeTap: () {
                  // Puedes eliminar si no usas los botones
                },
                onMapTap: () {},
                onHistoryTap: () {},
                onSettingsTap: () {},
                allAlerts: [],
              ),
              const FabGpsButton(),
            ],
          ),
        ),
      ),
    );
  }
}
