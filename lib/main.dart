import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import '../models/alert_message.dart';


void main() {
  runApp(const GlobalAlertGNSSApp());
}

class GlobalAlertGNSSApp extends StatelessWidget {
  const GlobalAlertGNSSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Alert GNSS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AlertMessage? _alert;

  @override
  void initState() {
    super.initState();
    _loadAlert();
  }

  Future<void> _loadAlert() async {
    final String response = await rootBundle.loadString('assets/alerts.json');
    final List<dynamic> data = jsonDecode(response);
    final alerts = data.map((json) => AlertMessage.fromJson(json)).toList();

    //final randomAlert = alerts[2];
    final randomAlert = alerts[Random().nextInt(alerts.length)];
    setState(() {
      _alert = randomAlert;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_alert == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Alert GNSS'),
        backgroundColor: Colors.red[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 100, color: Colors.red),
            const SizedBox(height: 25),
            Text(
              _alert!.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _alert!.message,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


