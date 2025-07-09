import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'map_controller.dart';
import 'map_sections.dart';
import 'fab_gps_button.dart';
import '../../models/alert_message_model.dart';
import '../alerts/alerts_screen.dart';
import '../settings/settings_screen.dart';
import '../home/home_screen.dart';

class MapScreen extends StatefulWidget {
  final List<AlertMessage> alerts;

  const MapScreen({super.key, required this.alerts});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late MapControllerState mapControllerState;

  @override
  void initState() {
    super.initState();
    mapControllerState = MapControllerState(vsync: this)..getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: mapControllerState,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E0F14),
        body: SafeArea(
          child: Stack(
            children: [
              MapSections(
                alerts: widget.alerts,
                onHomeTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                ),
                onMapTap: () {},
                onHistoryTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AlertsListScreen()),
                ),
                onSettingsTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
              const FabGpsButton(),
            ],
          ),
        ),
      ),
    );
  }
}
