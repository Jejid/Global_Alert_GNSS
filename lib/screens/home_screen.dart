import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:global_alert_gnss/screens/settings_screen.dart';
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
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
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
                child: Icon(Icons.location_on, color: color, size: 32),
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
    const backgroundColor = Color(0xFF0E0F14);
    const cardColor = Color(0xFF1A1C24);
    const footerColor = Color(0xFF14161F);
    const textColor = Colors.white;
    const secondaryText = Color(0xFF9ba1bb);

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Row(
                          children: [
                            const Icon(Icons.public, color: textColor, size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                loc.appTitle,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.person_rounded, color: Colors.white),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),

                      // Recent Alerts
                      _buildSectionTitle(loc.recentAlerts),
                      _recentAlerts.isEmpty
                          ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          loc.noRecentAlerts,
                          style: const TextStyle(color: secondaryText),
                        ),
                      )
                          : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _recentAlerts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final alert = _recentAlerts[index];
                          final icon = AlertUtils.getIconLucid(alert.type);
                          final color = AlertUtils.getAlertColor(alert.type);

                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AlertDetailScreen(alert: alert)),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(icon, color: Colors.white),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          alert.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: textColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          AlertUtils.formatTimestamp(alert.timestamp),
                                          style: const TextStyle(color: secondaryText, fontSize: 12),
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

                      // Map Section
                      _buildSectionTitle(loc.alertMap),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Navigation
            Container(
              color: footerColor,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFooterButton(icon:
                      Icons.home_rounded,
                      label: loc.home,
                      isActive: true,
                      onTap: () {}),
                  _buildFooterButton(
                    icon: Icons.map_rounded,
                    label: loc.alertMap,
                    isActive: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MapScreen(alerts: _monthlyAlerts)),
                      );
                    },
                  ),
                  _buildFooterButton(
                    icon: Icons.history_rounded,
                    label: loc.history,
                    isActive: false,
                    onTap: () {
                      Navigator.push(
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
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
