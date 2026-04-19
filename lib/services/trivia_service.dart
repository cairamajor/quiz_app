import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class TriviaService {
  static const _apiKey = 'qa_sk_cf4d352a95800ddb7e7ac62649f3f1e5397c1bfc';

  static Future<List<Question>> fetchQuestions() async {
    try {
      final response = await http.get(
        Uri.parse('https://quizapi.io/api/v1/questions?limit=10&random=true&api_key=$_apiKey'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('Status code: ${response.statusCode}');
      print('Body preview: ${response.body.substring(0, 200)}');

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map && decoded['data'] != null) {
          data = decoded['data'] as List<dynamic>;
        } else {
          throw Exception('Unexpected response format');
        }

        final questions = data
            .map((q) => Question.fromJson(q as Map<String, dynamic>))
            .where((q) => q.answers.isNotEmpty && q.correctAnswer.isNotEmpty)
            .toList();
        return questions;
      } else {
        print('Error body: ${response.body}');
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load questions');
    }
  }
}