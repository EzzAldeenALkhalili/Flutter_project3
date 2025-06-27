import 'package:flutter/material.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _round = 1;
  final int _totalRounds = 5;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..addStatusListener((status) {
      if (_finished) return;

      if (status == AnimationStatus.completed) {
        if (_round < _totalRounds) {
          setState(() {
            _round++;
          });
          _controller.reverse();
        } else {
          setState(() {
            _finished = true;
          });
        }
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF7FC),
      appBar: AppBar(title: const Text('Breathing Exercise')),
      body: Center(
        child: _finished
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Great job! You've completed your breathing exercise.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back to Exercises"),
            )
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween(begin: 0.7, end: 1.3).animate(CurvedAnimation(
                parent: _controller,
                curve: Curves.easeInOut,
              )),
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent,
                ),
                child: const Center(
                  child: Text(
                    'Breathe',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Inhale as it grows, exhale as it shrinks',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text("Round $_round of $_totalRounds",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
