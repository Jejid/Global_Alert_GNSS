import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../utils/alert_utils.dart';
import '../models/alert_message_model.dart';
import 'alert_detail_screen.dart';
import 'alerts_list_screen.dart';
import 'map_screen.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;

  List<AlertMessage> _recentAlerts = [];
  List<AlertMessage> _monthlyAlerts = [];
  List<Marker> _recentMarkers = [];

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();

    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final allAlerts = await AlertUtils.getAllAlerts();

    final recentAlerts = <AlertMessage>[];
    final monthAlerts = <AlertMessage>[];
    final recentMarkers = <Marker>[];

    for (final alert in allAlerts) {
      if (alert.timestamp.isAfter(thirtyDaysAgo) && alert.locations != null && alert.locations!.isNotEmpty) {
        monthAlerts.add(alert);

        if (alert.timestamp.isAfter(threeDaysAgo)) {
          recentAlerts.add(alert);
          final color = AlertUtils.getAlertColor(alert.type);
          for (final loc in alert.locations!) {
            recentMarkers.add(
              Marker(
                point: LatLng(loc.lat, loc.lon),
                width: 40,
                height: 40,
                child: Icon(
                  Icons.location_on,
                  color: color,
                  size: 32,
                ),
              ),
            );
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _recentAlerts = recentAlerts;
        _monthlyAlerts = monthAlerts;
        _recentMarkers = recentMarkers;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF101323);
    const secondaryBackgroundColor = Color(0xFF21284a);
    const footerBackgroundColor = Color(0xFF181d35);
    const textColor = Colors.white;
    const secondaryTextColor = Color(0xFF8e99cc);

    final sectionTitleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: textColor,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        color: backgroundColor,
                        child: Row(
                          children: [
                            const Spacer(),
                            Text(
                              'Alerts',
                              style: const TextStyle(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.015,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.settings, color: Colors.white),
                              onPressed: () {
                                // a futuro opciones sobre las alertas
                                // TODO: Acción configuración
                              },
                            ),
                          ],
                        ),
                      ),

                      // Latest Alerts Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Latest Alerts',
                            style: sectionTitleStyle?.copyWith(fontSize: 22),
                          ),
                        ),
                      ),

                      // Latest Alerts List (shrinkWrap: true)
                      if (_recentAlerts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'No recent alerts',
                            style: TextStyle(color: secondaryTextColor),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _recentAlerts.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final alert = _recentAlerts[index];
                            final color = AlertUtils.getAlertColor(alert.type);
                            final icon = AlertUtils.getIconLucid(alert.type);

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AlertDetailScreen(alert: alert),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: secondaryBackgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(icon, color: Colors.white, size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            alert.title,
                                            style: const TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            maxLines: 1,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            AlertUtils.formatTimestamp(alert.timestamp),
                                            style: TextStyle(
                                              color: secondaryTextColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      // Map Section Title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Map',
                            style: sectionTitleStyle?.copyWith(fontSize: 22),
                          ),
                        ),
                      ),

                      // Map with FlutterMap and markers
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => MapScreen(alerts: _monthlyAlerts)),
                                );
                              },
                              child: SizedBox(
                                height: 200,
                                child: IgnorePointer(
                                  ignoring: true,
                                  child: FlutterMap(
                                    options: MapOptions(
                                      initialCenter: LatLng(4.236479, -72.708779),
                                      initialZoom: 2,
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName: 'com.example.app',
                                      ),
                                      MarkerLayer(markers: _recentMarkers),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Navigation Bar
            Container(
              color: footerBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFooterButton(
                    icon: Icons.home,
                    label: 'Home',
                    isActive: true,
                    onTap: () {
                      // Ya estamos en Alerts
                    },
                  ),
                  _buildFooterButton(
                    icon: Icons.map_outlined,
                    label: 'Map',
                    isActive: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MapScreen(alerts: _monthlyAlerts)),
                      );
                    },
                  ),
                  _buildFooterButton(
                    icon: Icons.history,
                    label: 'Alerts',
                    isActive: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AlertsListScreen()),
                      );
                    },
                  ),
                  _buildFooterButton(
                    icon: Icons.settings,
                    label: 'Settings',
                    isActive: false,
                    onTap: () {
                      // Acción configuración
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
              letterSpacing: 0.015,
            ),
          ),
        ],
      ),
    );
  }
}
