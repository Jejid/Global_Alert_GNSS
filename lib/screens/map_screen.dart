import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:global_alert_gnss/screens/settings_screen.dart';
import 'package:latlong2/latlong.dart';
import '../models/alert_message_model.dart';
import '../utils/alert_utils.dart';
import '../screens/alert_detail_screen.dart';
import '../screens/alerts_list_screen.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';

class MapScreen extends StatelessWidget {
  final List<AlertMessage> alerts;

  const MapScreen({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0E0F14);
    const footerColor = Color(0xFF14161F);
    const textColor = Colors.white;
    const secondaryText = Color(0xFF9ba1bb);

    final loc = AppLocalizations.of(context)!;

    final markers = <Marker>[
      for (var alert in alerts)
        if (alert.locations != null)
          for (var loc in alert.locations!)
            Marker(
              width: 40,
              height: 40,
              point: LatLng(loc.lat, loc.lon),
              child: Icon(
                Icons.location_on,
                color: AlertUtils.getAlertColor(alert.type),
                size: 32,
              ),
            )
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.map_rounded, color: textColor, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      loc.alertMap,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Map Viewer
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: markers.isNotEmpty
                          ? markers.first.point
                          : const LatLng(4.236479, -72.708779),
                      initialZoom: 3.5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(markers: markers),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Footer Navigation Bar
            Container(
              color: footerColor,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFooterButton(
                    icon: Icons.home_rounded,
                    label: loc.home,
                    isActive: false,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                  ),
                  _buildFooterButton(
                    icon: Icons.map_rounded,
                    label: loc.alertMap,
                    isActive: true,
                    onTap: () {},
                  ),
                  _buildFooterButton(
                    icon: Icons.history_rounded,
                    label: loc.history,
                    isActive: false,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AlertsListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildFooterButton(
                    icon: Icons.settings_rounded,
                    label: loc.settings,
                    isActive: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    const activeColor = Colors.white;
    const inactiveColor = Color(0xFF8e99cc);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? activeColor : inactiveColor, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : inactiveColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
