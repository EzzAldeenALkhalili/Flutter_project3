import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:emoona/emotionAPI/emotion_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen({super.key});

  @override
  _JournalEntryScreenState createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _journalController = TextEditingController();
  bool _isLoading = false;
  String _emotion = "";
  String _greeting = "";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _suggestions = [
    "Feeling overwhelmed",
    "Had a good day",
    "Feeling stuck",
    "Grateful for something",
    "Anxious but hopeful"
  ];

  @override
  void initState() {
    super.initState();
    _setGreeting();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  void _setGreeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = "☀️ Good morning!";
    } else if (hour < 18) {
      _greeting = "🌙 Good evening!";
    } else {
      _greeting = "💤 Couldn't sleep?";
    }
  }

  String getEmoji(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'angry':
        return '😡';
      case 'neutral':
        return '😐';
      case 'surprised':
        return '😲';
      default:
        return '🤔';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _journalController.dispose();
    super.dispose();
  }

  void _insertSuggestion(String text) {
    setState(() {
      _journalController.text = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEBF7FC), Color(0xFFF9FCFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "📝 Journal Entry",
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat.yMMMMEEEEd().format(DateTime.now()),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          "How are you feeling today?",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Your emotions are valid. Let's explore them together.",
                        style: TextStyle(
                            fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 6),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.mic, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _journalController,
                                maxLines: null,
                                decoration:
                                const InputDecoration.collapsed(
                                  hintText:
                                  "Write about your feelings today...",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _suggestions
                            .map((text) => ActionChip(
                          label: Text(text),
                          onPressed: () => _insertSuggestion(text),
                        ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_journalController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Please enter your feelings first")),
                            );
                            return;
                          }

                          setState(() => _isLoading = true);

                          try {
                            final emotion =
                            await getEmotion(_journalController.text);

                            setState(() {
                              _emotion = emotion;
                              _isLoading = false;
                            });

                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .collection('journal_entries')
                                  .add({
                                'text': _journalController.text.trim(),
                                'emotion': emotion,
                                'date': Timestamp.now(),
                              });
                            }
                          } catch (e) {
                            setState(() => _isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                  Text("Failed to analyze emotion")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Center(
                            child: Text("Analyze Sentiment",
                                style: TextStyle(fontSize: 16))),
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (!_isLoading && _emotion.isNotEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("You seem to be feeling:",
                                  style: TextStyle(fontSize: 18)),
                              const SizedBox(height: 10),
                              Text(
                                _emotion.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                getEmoji(_emotion),
                                style: const TextStyle(fontSize: 40),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}