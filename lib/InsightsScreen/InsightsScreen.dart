import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {

  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final insights = [
      {
        "emoji": "📅",
        "title": "Happy Fridays!",
        "desc": "You've consistently had your best moods on Fridays."
      },
      {
        "emoji": "🌧️",
        "title": "Midweek Dip",
        "desc": "Wednesdays show a recurring drop in mood. Try lighter activities midweek."
      },
      {
        "emoji": "🧘",
        "title": "Relaxation Works",
        "desc": "Days with breathing exercises show improved moods the next day."
      },
      {
        "emoji": "💤",
        "title": "Better Sleep = Better Mood",
        "desc": "Logging your sleep has shown a positive impact on next-day feelings."
      }
    ];

    return Scaffold(
    backgroundColor: const Color(0xFFEBF7FC),
      appBar: AppBar(
       title: const Text("Emotional Insights"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: insights.length,
        itemBuilder: (context, index) {
          final item = insights[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            color: const Color(0xFFE1F5FE),
            child: ListTile(
              leading: Text(
                item["emoji"]!,
                style: const TextStyle(fontSize: 30),
              ),
              title: Text(
                item["title"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(item["desc"]!),
            ),
          );
        },
      ),
    );
  }
}
