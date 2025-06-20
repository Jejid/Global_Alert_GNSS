import 'package:flutter/material.dart';
import '../models/alert_message_model.dart';
import '../services/alert_service.dart';
import '../utils/alert_utils.dart';
import '../screens/alert_detail_screen.dart';
import '../l10n/app_localizations.dart';

class AlertsListScreen extends StatefulWidget {
  const AlertsListScreen({super.key});

  @override
  State<AlertsListScreen> createState() => _AlertsListScreenState();
}

class _AlertsListScreenState extends State<AlertsListScreen> {
  List<AlertMessage> _alerts = [];
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final alerts = await AlertService.loadAlerts();
    setState(() {
      _alerts = alerts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final types = _alerts.map((a) => a.type).toSet().toList();

    final filteredAlerts = _selectedType == null
        ? _alerts
        : _alerts.where((a) => a.type == _selectedType).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.alertsTitle),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: DropdownButtonFormField<String>(
              value: _selectedType,
              hint: Text(loc.filterByType, style: TextStyle(color: Colors.black)),
              items: types.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: filteredAlerts.isEmpty
                ? Center(child: Text(loc.noRecentAlerts))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredAlerts.length,
              itemBuilder: (context, i) {
                final alert = filteredAlerts[i];
                final color = AlertUtils.getAlertColor(alert.type);
                final icon = AlertUtils.getIconLucid(alert.type);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: color.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: Icon(icon, color: color),
                    title: Text(alert.title, style: const TextStyle(fontSize: 16)),
                    subtitle: Text(
                      alert.regions?.join(', ') ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Text(AlertUtils.formatTimestamp(alert.timestamp)),
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
