import 'dart:convert';
import 'package:http/http.dart' as http;

class HintService {
  static Future<String> getHint({
    required String question,
    required String correctAnswer,
    required String category,
  }) async {
    final uri = Uri.parse('https://api.anthropic.com/v1/messages');

    final prompt =
        'A student is taking a quiz and answered a question incorrectly.\n\n'
        'Question: $question\n'
        'Category: $category\n'
        'Correct Answer: $correctAnswer\n\n'
        'Give a short, helpful hint (2-3 sentences) that guides the student '
        'toward understanding the correct answer without giving it away directly. '
        'Be encouraging and educational.';

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'anthropic-version': '2023-06-01',
        'anthropic-dangerous-direct-browser-access': 'true',
      },
      body: jsonEncode({
        'model': 'claude-sonnet-4-20250514',
        'max_tokens': 200,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['content'] as List<dynamic>;
      final textBlock = content.firstWhere(
        (block) => block['type'] == 'text',
        orElse: () => {'text': 'Try reviewing the topic and think carefully.'},
      );
      return textBlock['text'] as String;
    } else {
      return 'Take your time and think about what you know about $category.';
    }
  }
}