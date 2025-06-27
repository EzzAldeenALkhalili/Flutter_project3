import 'package:flutter/material.dart';
import 'dart:math';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEBF7FC),
      appBar: AppBar(
        title: const Text("Alerts"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAlertCard(
            "We noticed 5 consecutive days of anxiety",
            "Try this anxiety relief exercise",
            Colors.orange[100]!,
            Icons.warning,
          ),
          _buildAlertCard(
            "Your mood improved 30% this week!",
            "Keep up the good work 🎉",
            Colors.green[100]!,
            Icons.celebration,
          ),
          _buildAlertCard(
            "No journal entry today",
            "Share how your day went",
            Colors.blue[100]!,
            Icons.edit,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/exercises');
        },
        child: const Icon(Icons.emoji_objects),
        tooltip: 'Explore Tips',
      ),
    );
  }

  Widget _buildAlertCard(String title, String subtitle, Color color, IconData icon) {
    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {},
        ),
      ),
    );
  }
}
