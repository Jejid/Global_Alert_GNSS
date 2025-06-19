import 'package:flutter/material.dart';
import 'alerts_list_screen.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Alert GNSS'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.warning),
          label: Text(loc.viewAlerts),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AlertsListScreen()),
            );
          },
        ),
      ),
    );
  }
}
