class Question {
  final String question;
  final List<String> answers;
  final String correctAnswer;
  final String category;
  final String difficulty;

  Question({
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.category,
    required this.difficulty,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final questionText = json['text'] ?? 'No question';

    final answers = <String>[];
    String correct = '';

    final answersList = json['answers'] as List<dynamic>? ?? [];

    for (final answer in answersList) {
      final map = answer as Map<String, dynamic>;
      final text = map['text']?.toString() ?? '';
      final isCorrect = map['isCorrect'] == true;

      if (text.isNotEmpty) {
        answers.add(text);
        if (isCorrect) correct = text;
      }
    }

    return Question(
      question: questionText,
      answers: answers,
      correctAnswer: correct,
      category: json['category']?.toString() ?? 'General',
      difficulty: json['difficulty']?.toString() ?? 'Easy',
    );
  }
}