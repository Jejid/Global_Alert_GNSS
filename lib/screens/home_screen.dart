import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'alert_detail_screen.dart';
import 'alerts_list_screen.dart';
import 'map_screen.dart';
import '../l10n/app_localizations.dart';
import '../utils/alert_utils.dart';
import '../models/alert_message_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  List<AlertMessage> _recentAlerts = [];
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    // Animación de entrada
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();

    // Cargar datos
    _loadRecentAlerts();
    _loadMarkers();
  }

  Future<void> _loadRecentAlerts() async {
    final now = DateTime.now();
    final allAlerts = await AlertUtils.getAllAlerts();

    setState(() {
      _recentAlerts = allAlerts.where((a) {
        final diff = now.difference(a.timestamp);
        return diff.inDays <= 3;
      }).toList();
    });
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

    final markers = recentAlerts.expand((a) {
      return a.locations!.map((loc) {
        return Marker(
          markerId: MarkerId('${a.id}_${loc.lat}_${loc.lon}'),
          position: LatLng(loc.lat, loc.lon),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            AlertUtils.getHue_forType(a.type),
          ),
          infoWindow: InfoWindow(
            title: a.title,
            snippet: a.message,
          ),
        );
      });
    }).toSet();

    setState(() {
      _markers = markers;
    });
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

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🆘 Sección de alertas recientes
              Text(
                loc.recentAlerts,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (_recentAlerts.isEmpty)
                Text(loc.noRecentAlerts),
              ..._recentAlerts.map((alert) {
                final color = AlertUtils.getAlertColor(alert.type);
                final icon = AlertUtils.getIconLucid(alert.type);
                return Card(
                  color: color.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    leading: Icon(icon, color: color),
                    title: Text(alert.title),
                    subtitle: Text(
                      alert.regions?.length == 1
                          ? '${loc.region} ${alert.regions!.first}'
                          : '${loc.regions} ${alert.regions?.join(", ")}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Text(
                      _formatTimestamp(alert.timestamp),
                      style: const TextStyle(fontSize: 12),
                    ),
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

              // 🗺️ Vista previa del mapa
              Text(
                loc.alertMap,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(0, 0),
                          zoom: 2,
                        ),
                        markers: _markers,
                        zoomControlsEnabled: false,
                        liteModeEnabled: true,
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MapScreen()),
                              );
                            },
                            splashColor: Colors.deepPurple.withOpacity(0.2),
                            highlightColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),


              // 📜 Ver historial
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.history),
                  label: Text(loc.viewHistory),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AlertsListScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}

