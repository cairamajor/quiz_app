import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/trivia_service.dart';
import '../services/hint_service.dart';
import '../widgets/answer_button.dart';
import '../widgets/hint_card.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answered = false;
  bool _loading = true;
  String? _error;
  late List<String> _shuffledAnswers;

  // Option 1: Hint state
  String? _hint;
  bool _hintLoading = false;
  bool _hintRequested = false;

  // Option 3: Track misses per category
  final Map<String, int> _categoryMisses = {};
  final Map<String, int> _categoryTotal = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await TriviaService.fetchQuestions();
      setState(() {
        _questions = questions;
        _loading = false;
        _shuffleAnswers();
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load questions for this category.\nTap retry to try a different category.';
        _loading = false;
      });
    }
  }

  void _shuffleAnswers() {
    _shuffledAnswers = List.from(_questions[_currentIndex].answers)..shuffle();
  }

  void _selectAnswer(String answer) {
    if (_answered) return;
    final q = _questions[_currentIndex];
    final isCorrect = answer == q.correctAnswer;

    _categoryTotal[q.category] = (_categoryTotal[q.category] ?? 0) + 1;
    if (!isCorrect) {
      _categoryMisses[q.category] = (_categoryMisses[q.category] ?? 0) + 1;
    }

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (isCorrect) _score++;
    });
  }

  Future<void> _requestHint() async {
    final q = _questions[_currentIndex];
    setState(() {
      _hintLoading = true;
      _hintRequested = true;
    });

    final hint = await HintService.getHint(
      question: q.question,
      correctAnswer: q.correctAnswer,
      category: q.category,
    );

    setState(() {
      _hint = hint;
      _hintLoading = false;
    });
  }

  void _nextQuestion() {
    if (_currentIndex + 1 >= _questions.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            score: _score,
            total: _questions.length,
            categoryMisses: _categoryMisses,
            categoryTotal: _categoryTotal,
          ),
        ),
      );
    } else {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
        _hint = null;
        _hintLoading = false;
        _hintRequested = false;
        _shuffleAnswers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/thinking.png', height: 120),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Loading questions...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                      _error = null;
                    });
                    _loadQuestions();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final q = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text('Question ${_currentIndex + 1} of ${_questions.length}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.indigo.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(q.category, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.indigo.shade100,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(q.difficulty, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.green.shade100,
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.shade100,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                q.question,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),

            ..._shuffledAnswers.map((a) => AnswerButton(
              text: a,
              answered: _answered,
              isCorrect: a == q.correctAnswer,
              isSelected: a == _selectedAnswer,
              onTap: () => _selectAnswer(a),
            )),

            if (_answered && _selectedAnswer != q.correctAnswer) ...[
              const SizedBox(height: 8),
              if (!_hintRequested)
                OutlinedButton.icon(
                  onPressed: _requestHint,
                  icon: Image.asset('assets/icons/hint.png', width: 18, height: 18),
                  label: const Text('Get a Hint'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.amber.shade800,
                    side: BorderSide(color: Colors.amber.shade400),
                  ),
                ),
              if (_hintRequested)
                HintCard(
                  hint: _hint ?? '',
                  isLoading: _hintLoading,
                ),
            ],

            if (_answered) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentIndex + 1 < _questions.length
                      ? 'Next Question →'
                      : 'See Results',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}