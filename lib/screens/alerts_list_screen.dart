import 'package:flutter/material.dart';
import '../models/alert_message_model.dart';
import '../services/alert_service.dart';
import '../utils/alert_utils.dart';
import '../screens/alert_detail_screen.dart';
import '../l10n/app_localizations.dart';
import 'map_screen.dart';

class AlertsListScreen extends StatefulWidget {
  const AlertsListScreen({super.key});

  @override
  State<AlertsListScreen> createState() => _AlertsListScreenState();
}

class _AlertsListScreenState extends State<AlertsListScreen> {
  List<AlertMessage> _alerts = [];
  List<AlertMessage> _filteredAlerts = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final alerts = await AlertService.loadAlerts();
    setState(() {
      _alerts = alerts;
      _filteredAlerts = alerts;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredAlerts = _alerts;
      } else {
        _filteredAlerts = _alerts.where((alert) {
          final titleLower = alert.title.toLowerCase();
          final regionsLower = alert.regions?.join(', ').toLowerCase() ?? '';
          return titleLower.contains(_searchQuery) || regionsLower.contains(_searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF101323);
    const inputBackgroundColor = Color(0xFF21284a);
    const footerBackgroundColor = Color(0xFF181d35);
    const textColor = Colors.white;
    const secondaryTextColor = Color(0xFF8e99cc);

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: backgroundColor,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  // Icon "List"
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.list,
                      color: textColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc.alertsTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.015,
                      ),
                    ),
                  ),
                  // Spacer to balance the row (same width as icon)
                  const SizedBox(width: 36),
                ],
              ),
            ),

            // Search input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: inputBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: textColor, fontSize: 16),
                  cursorColor: textColor,
                  decoration: InputDecoration(
                    hintText: loc.searchAlerts,
                    // Asegúrate que exista en arb
                    hintStyle: TextStyle(color: secondaryTextColor),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Alerts list
            Expanded(
              child: _filteredAlerts.isEmpty
                  ? Center(
                child: Text(
                  loc.noRecentAlerts,
                  style: TextStyle(color: secondaryTextColor, fontSize: 16),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredAlerts.length,
                itemBuilder: (context, index) {
                  final alert = _filteredAlerts[index];
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
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: inputBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon container con color de alerta y icono blanco
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Icon(icon, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          // Textos
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
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
            ),

            // Footer Navigation Bar (igual que HomeScreen)
            Container(
              color: footerBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFooterButton(
                    icon: Icons.home,
                    label: loc.home,
                    isActive: false,
                    onTap: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                  _buildFooterButton(
                    icon: Icons.map_outlined,
                    label: loc.alertMap,
                    isActive: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) =>
                            MapScreen(alerts: _alerts)),
                      );
                    },
                  ),
                  _buildFooterButton(
                    icon: Icons.history,
                    label: loc.history,
                    isActive: true,
                    onTap: () {
                      // Ya estamos aquí
                    },
                  ),
                  _buildFooterButton(
                    icon: Icons.settings,
                    label: loc.appTitle,
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
      behavior: HitTestBehavior.opaque,
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
