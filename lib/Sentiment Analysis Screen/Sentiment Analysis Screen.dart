import 'package:flutter/material.dart';
import 'dart:math';

class SentimentAnalysisScreen extends StatelessWidget {
  const SentimentAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? journalText = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      backgroundColor: Color(0xFFEBF7FC),
      appBar: AppBar(
        title: const Text("Sentiment Analysis"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Re-analyzing sentiment...")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (journalText != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(journalText),
              ),

            // Analysis Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[100]!,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "Analysis Results",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Today's emotions: Sad 70%, Anxious 20%, Positive 10%",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 150,
                    child: CustomPaint(
                      painter: _SentimentChartPainter(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Suggestions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[200]!,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Mood Improvement Suggestions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildSuggestionItem("5-minute breathing exercise"),
                  _buildSuggestionItem("Listen to calming music"),
                  _buildSuggestionItem("Talk to a close friend"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/exercises');
              },
              icon: const Icon(Icons.emoji_objects, color: Colors.white),
              label: const Text("What can I do now?",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[300]!,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _SentimentChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [Colors.red, Colors.blue, Colors.green];
    final values = [70, 20, 10];
    final total = values.reduce((a, b) => a + b);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    double startAngle = -90 * (pi / 180);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 360 * (pi / 180);
      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
