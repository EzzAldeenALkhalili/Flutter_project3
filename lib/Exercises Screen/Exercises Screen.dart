import 'package:flutter/material.dart';

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEBF7FC),
      appBar: AppBar(
        title: const Text("Exercises & Help"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(

          children: [
            _buildExerciseCard(
              context,
              "Breathing Exercises",
              "Take 5 deep breaths 🧘‍♂️",
              Icons.self_improvement,
              Colors.blue[100]!,
              onTryNow: () => Navigator.pushNamed(context, '/breathing'),
            ),
            _buildExerciseCard(
              context,
              "Gratitude Journal",
              "Write 3 things you're grateful for ✍️",
              Icons.edit,
              Colors.green[100]!,
              onTryNow: () => Navigator.pushNamed(context, '/gratitude'),
            ),
            _buildExerciseCard(
              context,
              "Quick Walk",
              "Walk outdoors for 10 minutes 🚶‍♂️",
              Icons.directions_walk,
              Colors.purple[100]!,
              onTryNow: () => Navigator.pushNamed(context, '/walk'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Emergency Help"),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Mental Health Hotline: 123456789"),
                        SizedBox(height: 16),
                        Text("Emergency Services: 112"),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("I Need Immediate Help",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
      BuildContext context,
      String title,
      String description,
      IconData icon,
      Color color, {
        VoidCallback? onTryNow,
      }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 32, color: Colors.black),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  child: const Text("Save",
                    style: TextStyle(color: Colors.blueAccent),),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onTryNow ?? () {},
                  child: const Text("Try Now",
                    style: TextStyle(color: Colors.blueAccent),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
