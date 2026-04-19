class Question {
  final String question;
  final List<String> answers;
  final String correctAnswer;

  Question({
    required this.question,
    required this.answers,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<String> answers = [];

    json['answers'].forEach((key, value) {
      if (value != null) {
        answers.add(value);
      }
    });

    String correct = "";

    json['correct_answers'].forEach((key, value) {
      if (value == "true") {
        correct = key.replaceAll("_correct", "");
      }
    });

    return Question(
      question: json['question'],
      answers: answers,
      correctAnswer: correct,
    );
  }
}