import 'package:flutter/material.dart';
import 'alerts_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Alert GNSS'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.warning),
          label: const Text('Ver Alertas en mi zona'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
