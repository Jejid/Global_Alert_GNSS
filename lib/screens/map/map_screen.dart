import 'package:flutter/material.dart';
import 'package:global_alert_gnss/utils/alert_utils.dart';
import 'package:provider/provider.dart';

import 'map_controller.dart';
import 'map_sections.dart';
import 'fab_gps_button.dart';
import '../../providers/map_state_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

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
    mapControllerState = MapControllerState(vsync: this)..getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    final alerts = context.watch<MapStateProvider>().alerts;

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
