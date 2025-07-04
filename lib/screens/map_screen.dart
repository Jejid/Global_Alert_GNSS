import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:global_alert_gnss/screens/settings_screen.dart';
import '../models/alert_message_model.dart';
import '../utils/alert_utils.dart';
import '../screens/alert_detail_screen.dart';
import '../screens/alerts_list_screen.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';

class MapScreen extends StatefulWidget {
  final List<AlertMessage> alerts;

  const MapScreen({super.key, required this.alerts});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _userLocation;
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    final userLatLng = LatLng(position.latitude, position.longitude);
    setState(() => _userLocation = userLatLng);
    _mapController.move(userLatLng, 12);
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0E0F14);
    const footerColor = Color(0xFF14161F);
    const textColor = Colors.white;
    const secondaryText = Color(0xFF9ba1bb);

    final loc = AppLocalizations.of(context)!;

    final markers = <Marker>[
      for (var alert in widget.alerts)
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
            ),
      if (_userLocation != null)
        Marker(
          width: 36,
          height: 36,
          point: _userLocation!,
          child: const Icon(Icons.my_location_rounded, color: Colors.blueAccent, size: 30),
        ),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
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

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _userLocation ?? const LatLng(4.236479, -72.708779),
                          initialZoom: 2.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(markers: markers),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

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
                            MaterialPageRoute(builder: (_) => const AlertsListScreen()),
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
            Positioned(
              bottom: 85,
              right: 18,
              child: FloatingActionButton.small(
                backgroundColor: Colors.black54,
                onPressed: _getUserLocation,
                child: const Icon(Icons.my_location, color: Colors.white),
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
