import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../utils/alert_utils.dart';
import '../models/alert_message_model.dart';
import 'alert_detail_screen.dart';
import 'alerts_list_screen.dart';
import 'map_screen_new.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;

  List<AlertMessage> _recentAlerts = [];
  List<Marker> _markers = [];

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

    _loadRecentAlerts();
    _loadMarkers();
  }

  Future<void> _loadRecentAlerts() async {
    final now = DateTime.now();
    final allAlerts = await AlertUtils.getAllAlerts();

    if (mounted) {
      setState(() {
        _recentAlerts = allAlerts.where((a) {
          final diff = now.difference(a.timestamp);
          return diff.inDays <= 3;
        }).toList();
      });
    }
  }

  Future<void> _loadMarkers() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final allAlerts = await AlertUtils.getAllAlerts();

    final recentAlerts = allAlerts.where((a) {
      return a.timestamp.isAfter(thirtyDaysAgo) &&
          a.locations != null &&
          a.locations!.isNotEmpty;
    }).toList();

    final List<Marker> markers = [];

    for (final alert in recentAlerts) {
      final color = AlertUtils.getAlertColor(alert.type);
      for (final loc in alert.locations!) {
        markers.add(
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

    if (mounted) {
      setState(() {
        _markers = markers;
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
    final loc = AppLocalizations.of(context)!;
    const primaryColor = Colors.deepPurple;
    const accentColor = Colors.cyan;

    final sectionTitleStyle = Theme.of(context).textTheme.titleLarge!.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle, style: const TextStyle(letterSpacing: 1.2)),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(loc.recentAlerts, style: sectionTitleStyle),
              const SizedBox(height: 12),
              if (_recentAlerts.isEmpty)
                Text(loc.noRecentAlerts),
              ..._recentAlerts.map((alert) {
                final color = AlertUtils.getAlertColor(alert.type);
                final icon = AlertUtils.getIconLucid(alert.type);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: color.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: Icon(icon, color: color),
                    title:
                    Text(alert.title, style: const TextStyle(fontSize: 16)),
                    subtitle: Text(
                      alert.regions?.join(', ') ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing:
                    Text(AlertUtils.formatTimestamp(alert.timestamp)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AlertDetailScreen(alert: alert),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),
              const Divider(thickness: 1.2),
              const SizedBox(height: 24),

              Text(loc.alertMap, style: sectionTitleStyle),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MapScreen()),
                  );
                },
                child: SizedBox(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AbsorbPointer(
                      child: FlutterMap(
                        options: MapOptions(
                          center: LatLng(4.236479, -72.708779),
                          zoom: 2.5,
                          interactiveFlags: InteractiveFlag.none,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(markers: _markers),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Divider(thickness: 1.2),
              const SizedBox(height: 24),

              Text(loc.viewHistory, style: sectionTitleStyle),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.history, color: Colors.blueGrey),
                label: Text(
                  loc.viewHistory,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.blueGrey),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AlertsListScreen()),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}