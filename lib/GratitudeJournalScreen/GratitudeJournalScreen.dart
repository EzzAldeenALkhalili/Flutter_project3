import 'package:flutter/material.dart';

class GratitudeJournalScreen extends StatefulWidget {
  const GratitudeJournalScreen({super.key});

  @override
  State<GratitudeJournalScreen> createState() => _GratitudeJournalScreenState();
}

class _GratitudeJournalScreenState extends State<GratitudeJournalScreen> {
  final List<String> _entries = ['', '', ''];
  bool _submitted = false;

  void _submitEntries() {
    if (_entries.every((entry) => entry.trim().isNotEmpty)) {
      setState(() {
        _submitted = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all three entries.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEBF7FC),
      appBar: AppBar(title: const Text("Gratitude Journal")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _submitted
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, color: Colors.pink, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Beautiful! You've reflected on your gratitude.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text("Back to Exercises",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Write 3 things you're grateful for today:",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            for (int i = 0; i < _entries.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Gratitude #${i + 1}',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) => _entries[i] = value,
                ),
              ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitEntries,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text("Submit",
    style: TextStyle(color: Colors.white),
    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
