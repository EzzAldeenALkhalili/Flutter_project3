import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Screens
import 'SplashScreen/SplashScreen.dart';
import 'Login Screen/Login Screen.dart';
import 'SignUp Screen/SignUp Screen.dart';
import 'Dashboard Screen/Dashboard Screen.dart';
import 'Journal Entry Screen/Journal Entry Screen.dart';
import 'Sentiment Analysis Screen/Sentiment Analysis Screen.dart';
import 'Settings Screen/Settings Screen.dart';
import 'AlertsScreen/AlertsScreen.dart';
import 'Exercises Screen/Exercises Screen.dart';
import 'EmotionHistoryScreen/EmotionHistoryScreen.dart';
import 'InsightsScreen/InsightsScreen.dart';
import 'BreathingExerciseScreen/BreathingExerciseScreen.dart';
import 'GratitudeJournalScreen/GratitudeJournalScreen.dart';
import 'QuickWalkScreen/QuickWalkScreen.dart';
import 'ChatbotScreen/ChatbotScreen.dart';
import 'JournalHistoryScreen/JournalHistoryScreen.dart'; // ✅ جديد

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/journal': (context) => const JournalEntryScreen(),
        '/sentiment': (context) => const SentimentAnalysisScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/alerts': (context) => const AlertsScreen(),
        '/exercises': (context) => const ExercisesScreen(),
        '/history': (context) => const EmotionHistoryScreen(),
        '/insights': (context) => const InsightsScreen(),
        '/breathing': (context) => const BreathingExerciseScreen(),
        '/gratitude': (context) => const GratitudeJournalScreen(),
        '/walk': (context) => const QuickWalkScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/journal_history': (context) => const JournalHistoryScreen(), // ✅ أضفناها
      },
    );
  }
}
