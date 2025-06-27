import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<String> getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data()?['name'] ?? 'User';
    }
    return 'User';
  }

  Future<Map<String, dynamic>> fetchMoodData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {'moods': [], 'summary': 'No data'};

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journal_entries')
        .orderBy('date', descending: true)
        .limit(7)
        .get();

    List<double> moodValues = [];
    int happy = 0, sad = 0, angry = 0, surprised = 0;

    for (var doc in snapshot.docs.reversed) { // نرجّع الترتيب الطبيعي
      String emotion = doc['emotion']?.toString().toLowerCase().trim() ?? '';
      print("Detected Emotion: $emotion");

      if ([
        'admiration', 'amusement', 'desire', 'approval', 'caring',
        'excitement', 'gratitude', 'joy', 'love', 'optimism',
        'pride', 'relief', 'happy'
      ].contains(emotion)) {
        moodValues.add(1.0);
        happy++;
      } else if ([
        'disappointment', 'grief', 'nervousness', 'remorse',
        'sadness', 'embarrassment', 'sad'
      ].contains(emotion)) {
        moodValues.add(0.2);
        sad++;
      } else if ([
        'anger', 'annoyance', 'fear', 'disapproval', 'disgust', 'angry'
      ].contains(emotion)) {
        moodValues.add(0.4);
        angry++;
      } else if ([
        'curiosity', 'confusion', 'realization', 'surprise', 'surprised'
      ].contains(emotion)) {
        moodValues.add(0.6);
        surprised++;
      } else {
        moodValues.add(0.2); // fallback = Sad
        sad++;
      }
    }

    String summary = 'No data';
    final counts = {
      '😊 Happy': happy,
      '😢 Sad': sad,
      '😠 Angry': angry,
      '😮 Surprised': surprised,
    };
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.isNotEmpty && sorted.first.value > 0) {
      summary = sorted.first.key;
    }

    return {
      'moods': moodValues, // بدون reverse
      'summary': summary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF7FC),
      appBar: AppBar(
        title: const Text("Mental Health Tracker"),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.pushNamed(context, '/settings')),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () => Navigator.pushNamed(context, '/alerts')),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => _logout(context)),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchMoodData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final moodValues = snapshot.data!['moods'] as List<double>;
          final summary = snapshot.data!['summary'] as String;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.lightBlueAccent,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    FutureBuilder<String>(
                      future: getUserName(),
                      builder: (context, userSnap) {
                        return Text(
                          "Hello, ${userSnap.data ?? '...'}!",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text("How are you feeling today?", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8BD7DE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Today's Mood Summary",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "You're mostly feeling: $summary",
                        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Keep going, you're doing great!",
                        style: TextStyle(fontSize: 15, color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/journal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Journal Your Feelings Now", style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                moodValues.isEmpty
                    ? const Text("No mood data available.")
                    : Container(
                  width: double.infinity,
                  height: 260,
                  padding: const EdgeInsets.only(left: 48, right: 16, top: 16, bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: CustomPaint(painter: _DynamicLineChartPainter(moodValues)),
                ),
                const SizedBox(height: 24),
                const Text("Weekly Mood Progression", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF7FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.notifications, color: Colors.orange),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text("We noticed you’ve had some negative emotions recently. Want help?",
                            style: TextStyle(fontSize: 14)),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickAccessButton(Icons.analytics, "Sentiment", context, '/sentiment'),
                    _buildQuickAccessButton(Icons.self_improvement, "Exercises", context, '/exercises'),
                    _buildQuickAccessButton(Icons.emoji_objects, "Insights", context, '/insights'),
                    _buildQuickAccessButton(Icons.chat, "Chatbot", context, '/chatbot'),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/journal_history'),
                  icon: const Icon(Icons.menu_book, color: Colors.white),
                  label: const Text("View Journal History", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/history'),
                  icon: const Icon(Icons.history, color: Colors.white),
                  label: const Text("View Mood History", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAccessButton(IconData icon, String label, BuildContext context, String route) {
    return Column(
      children: [
        IconButton(icon: Icon(icon), iconSize: 32, color: Colors.teal, onPressed: () => Navigator.pushNamed(context, route)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
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
      ..shader = const LinearGradient(
        colors: [Color(0xFF6A5AE0), Color(0xFF00C9A7)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
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
      textPainter.text = TextSpan(
        text: days[i % 7],
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(points[i].dx - textPainter.width / 2, size.height + 6));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
