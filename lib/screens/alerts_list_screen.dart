import 'package:flutter/material.dart';
import '../models/alert_message_model.dart';
import '../services/alert_service.dart';
import '../utils/alert_utils.dart';
import 'alert_detail_screen.dart';
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
      _filteredAlerts = _searchQuery.isEmpty
          ? _alerts
          : _alerts.where((alert) {
        final title = alert.title.toLowerCase();
        final regions = alert.regions?.join(', ').toLowerCase() ?? '';
        return title.contains(_searchQuery) || regions.contains(_searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0E0F14);
    const cardColor = Color(0xFF1A1C24);
    const inputBackgroundColor = Color(0xFF1E2233);
    const footerColor = Color(0xFF14161F);
    const textColor = Colors.white;
    const secondaryText = Color(0xFF9ba1bb);

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  const Icon(Icons.list_rounded, color: textColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      loc.alertsTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Opacity(
                    opacity: 0,
                    child: Icon(Icons.list_rounded, size: 28),
                  ), // balance visual
                ],
              ),
            ),

            // Search box
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: inputBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: textColor),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: loc.searchAlerts,
                    hintStyle: const TextStyle(color: secondaryText),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: secondaryText),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // List or empty state
            Expanded(
              child: _filteredAlerts.isEmpty
                  ? Center(
                child: Text(
                  loc.noRecentAlerts,
                  style: const TextStyle(color: secondaryText, fontSize: 16),
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
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
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
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AlertUtils.formatTimestamp(alert.timestamp),
                                  style: const TextStyle(
                                    color: secondaryText,
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

            // Footer nav bar
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
                    onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                  ),
                  _buildFooterButton(
                    icon: Icons.map_rounded,
                    label: loc.alertMap,
                    isActive: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MapScreen(alerts: _alerts)),
                      );
                    },
                  ),
                  _buildFooterButton(
                    icon: Icons.history_rounded,
                    label: loc.history,
                    isActive: true,
                    onTap: () {}, // ya está aquí
                  ),
                  _buildFooterButton(
                    icon: Icons.settings_rounded,
                    label: loc.appTitle,
                    isActive: false,
                    onTap: () {
                      // navegación futura
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
