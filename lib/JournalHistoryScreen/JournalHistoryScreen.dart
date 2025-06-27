import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class JournalHistoryScreen extends StatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  State<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends State<JournalHistoryScreen> {
  List<QueryDocumentSnapshot> _entries = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  Future<void> _fetchEntries() async {
    setState(() => _isLoading = true);

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journal_entries')
        .orderBy('date', descending: true);

    if (_startDate != null && _endDate != null) {
      query = query
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(_endDate!));
    }

    final snapshot = await query.get();
    setState(() {
      _entries = snapshot.docs;
      _isLoading = false;
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchEntries();
    }
  }

  Future<void> _deleteEntry(String docId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('journal_entries')
        .doc(docId)
        .delete();

    _fetchEntries();
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
      case 'joy':
        return '😊';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'surprised':
        return '😮';
      case 'neutral':
      case 'calm':
        return '😐';
      case 'anxious':
        return '😟';
      case 'grateful':
        return '🙏';
      case 'excited':
        return '😄';
      default:
        return '🤔';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF7FC),
      appBar: AppBar(
        title: const Text("Journal History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Filter by Date',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.menu_book_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No journal entries found.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];
          final text = entry['text'] ?? '';
          final emotion = entry['emotion'] ?? '';
          final date = (entry['date'] as Timestamp).toDate();
          final emoji = _getEmotionEmoji(emotion);

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('yMMMEd – h:mm a').format(date),
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteEntry(entry.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    text,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text("Detected Emotion: $emotion",
                          style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
