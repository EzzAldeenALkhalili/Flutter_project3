import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmotionHistoryScreen extends StatefulWidget {
  const EmotionHistoryScreen({super.key});

  @override
  State<EmotionHistoryScreen> createState() => _EmotionHistoryScreenState();
}

class _EmotionHistoryScreenState extends State<EmotionHistoryScreen> {
  List<double> moodData = [];
  double average = 0.0;
  bool isLoading = true;
  String mostFrequentMood = '';
  double lastWeekAverage = 0.0;

  @override
  void initState() {
    super.initState();
    fetchMoodValues();
  }

  Future<void> fetchMoodValues() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journal_entries')
        .orderBy('date', descending: true)
        .limit(14)
        .get();

    final recentDocs = snapshot.docs.take(7).toList().reversed.toList();
    final lastWeekDocs = snapshot.docs.skip(7).take(7).toList();

    final recent = recentDocs.map((doc) => emotionToScore(doc['emotion'])).toList();
    final last = lastWeekDocs.map((doc) => emotionToScore(doc['emotion'])).toList();

    setState(() {
      moodData = recent;
      average = recent.isNotEmpty ? recent.reduce((a, b) => a + b) / recent.length : 0.0;
      lastWeekAverage = last.isNotEmpty ? last.reduce((a, b) => a + b) / last.length : 0.0;
      mostFrequentMood = getMostFrequentEmotion(recentDocs.map((doc) => doc['emotion'].toString()).toList());
      isLoading = false;
    });
  }

  double emotionToScore(String emotion) {
    final e = emotion.toLowerCase().trim();
    if ([
      'admiration', 'amusement', 'desire', 'approval', 'caring',
      'excitement', 'gratitude', 'joy', 'love', 'optimism',
      'pride', 'relief', 'happy'
    ].contains(e)) {
      return 1.0; // Happy
    } else if ([
      'disappointment', 'grief', 'nervousness', 'remorse',
      'sadness', 'embarrassment', 'sad'
    ].contains(e)) {
      return 0.2; // Sad
    } else if ([
      'anger', 'annoyance', 'fear', 'disapproval', 'disgust', 'angry'
    ].contains(e)) {
      return 0.4; // Angry
    } else if ([
      'curiosity', 'confusion', 'realization', 'surprise', 'surprised'
    ].contains(e)) {
      return 0.6; // Surprised
    } else {
      return 0.2; // Default fallback = Sad
    }
  }

  String getFeedbackText() {
    if (average > 0.7) return "You're doing great! Keep it up!";
    if (average >= 0.4) return "You're doing okay, try to stay balanced.";
    return "It's okay to feel down. Consider doing a breathing or gratitude exercise.";
  }

  String getEmoji() {
    if (average > 0.7) return "😄";
    if (average >= 0.4) return "😐";
    return "😢";
  }

  String getMostFrequentEmotion(List<String> emotions) {
    final counts = <String, int>{};
    for (var e in emotions) {
      counts[e] = (counts[e] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.isNotEmpty ? sorted.first.key : '';
  }

  Widget buildRecommendationCard() {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMoodButton("Breathing", Icons.self_improvement, '/breathing', Colors.blueAccent),
              const SizedBox(width: 12),
              _buildMoodButton("Gratitude", Icons.favorite, '/gratitude', Colors.green),
              const SizedBox(width: 12),
              _buildMoodButton("Try Exercises", Icons.bolt, '/exercises', Colors.deepPurple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodButton(String label, IconData icon, String route, Color color) {
    return ElevatedButton.icon(
      onPressed: average < 0.5 ? () => Navigator.pushNamed(context, route) : null,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withOpacity(0.3),
        disabledForegroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  Widget buildSummaryCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.teal),
                const SizedBox(width: 8),
                const Text("Average Mood Score", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Text("${average.toStringAsFixed(2)} / 1.0 ${getEmoji()}",
                    style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Text(getFeedbackText(), style: const TextStyle(color: Colors.orange, fontSize: 14)),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.timeline, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text("Compared to last week: ", style: TextStyle(color: Colors.indigo)),
                Text((average - lastWeekAverage).toStringAsFixed(2),
                    style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.emoji_emotions, color: Colors.brown),
                const SizedBox(width: 8),
                Text("Most Frequent Emotion: $mostFrequentMood", style: const TextStyle(color: Colors.brown)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF7FC),
      appBar: AppBar(
        title: const Text("Mood History"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your Mood Over the Last 7 Days", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 260,
              padding: const EdgeInsets.only(left: 48, right: 16, top: 16, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))],
              ),
              child: CustomPaint(
                size: const Size(double.infinity, double.infinity),
                painter: _DynamicLineChartPainter(moodData),
              ),
            ),
            const SizedBox(height: 24),
            buildSummaryCard(),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: const Text(
                "Tip 💡: Try writing your journal earlier in the day when you’re more aware of your feelings.",
                style: TextStyle(color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),
            buildRecommendationCard(),
          ],
        ),
      ),
    );
  }
}

class _DynamicLineChartPainter extends CustomPainter {
  final List<double> moodValues;
  _DynamicLineChartPainter(this.moodValues);

  @override
  void paint(Canvas canvas, Size size) {
    final moodLabels = ['Sad', 'Angry', 'Surprised', 'Happy'];
    final moodLevelsY = [0.2, 0.4, 0.6, 1.0];

    final linePaint = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFF6A5AE0), Color(0xFF00C9A7)])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = const Color(0xFF6A5AE0).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final labelPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < moodLabels.length; i++) {
      final y = size.height * (1 - moodLevelsY[i]);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), Paint()..color = Colors.grey[300]!);

      labelPainter.text = TextSpan(
        text: moodLabels[i],
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333366)),
      );
      labelPainter.layout();
      labelPainter.paint(canvas, Offset(-40, y - labelPainter.height / 2));
    }

    final points = List<Offset>.generate(moodValues.length, (i) {
      final x = size.width / (moodValues.length - 1) * i;
      final y = size.height * (1 - moodValues[i]);
      return Offset(x, y);
    });

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        final prev = points[i - 1];
        final curr = points[i];
        final midX = (prev.dx + curr.dx) / 2;
        path.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
      }
      canvas.drawPath(path, linePaint);
    }

    for (final point in points) {
      canvas.drawCircle(point, 8, glowPaint);
      canvas.drawCircle(point, 5, Paint()..color = Colors.deepPurple);
    }

    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < points.length; i++) {
      textPainter.text = TextSpan(text: days[i % 7], style: const TextStyle(fontSize: 12, color: Colors.grey));
      textPainter.layout();
      textPainter.paint(canvas, Offset(points[i].dx - textPainter.width / 2, size.height + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
