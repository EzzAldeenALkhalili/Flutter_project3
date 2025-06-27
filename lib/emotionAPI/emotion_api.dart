import 'dart:convert';
import 'package:http/http.dart' as http;


Future<String> getEmotion(String text) async {
  final url = Uri.parse('https://emotion-api-8dpt.onrender.com/predict-emotion');

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"text": text}),
  );

  if (response.statusCode == 200) {
    // Parse the response JSON
    final data = jsonDecode(response.body);
    return data['emotion'];
  } else {
    throw Exception('Failed to get emotion prediction');
  }
}
