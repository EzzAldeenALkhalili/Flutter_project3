import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> getChatbotReply(String prompt) async {
  const apiKey = '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'; // ✅ حط مفتاحك هون بدل xxxxx

  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "system", "content": "You are a helpful and friendly mental health assistant."},
        {"role": "user", "content": prompt}
      ]
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  } else {
    throw Exception("Failed to fetch response: ${response.body}");
  }
}
