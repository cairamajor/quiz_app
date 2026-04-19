import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class TriviaService {
  static const String _baseUrl = 'https://quizapi.io/api/v1/questions';
  static const String _apiKey = 'qa_sk_cf4d352a95800ddb7e7ac62649f3f1e5397c1bfc';

  static Future<List<Question>> fetchQuestions() async {
    if (_apiKey.trim().isEmpty) {
      throw Exception('Missing API key');
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'limit': '10',
      'offset': '0',
      'category': 'Programming',
      'difficulty': 'EASY',
      'type': 'MULTIPLE_CHOICE',
      'random': 'true',
    });

    try {
      final response = await http
          .get(uri, headers: {'Authorization': 'Bearer $_apiKey'})
          .timeout(const Duration(seconds: 10));

      print('Status code: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('HTTP error: ${response.statusCode}');
      }

      final body = json.decode(response.body) as Map<String, dynamic>;

      if (body['success'] == true && body['data'] is List) {
        final results = body['data'] as List;
        final questions = results
            .map((e) => Question.fromJson(e as Map<String, dynamic>))
            .where((q) => q.answers.isNotEmpty && q.correctAnswer.isNotEmpty)
            .toList();

        if (questions.isEmpty) {
          throw Exception('No valid questions returned');
        }

        return questions;
      } else {
        throw Exception('API returned success=false or no data');
      }

    } catch (e) {
      print('Error: $e');
      throw Exception('Could not load questions: $e');
    }
  }
}