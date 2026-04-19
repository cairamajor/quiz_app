import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class ResultsScreen extends StatelessWidget {
  final int score;
  final int total;
  final Map<String, int> categoryMisses;
  final Map<String, int> categoryTotal;

  const ResultsScreen({
    super.key,
    required this.score,
    required this.total,
    required this.categoryMisses,
    required this.categoryTotal,
  });

  String get _feedbackMessage {
    final ratio = score / total;
    if (ratio == 1.0) return 'Perfect score! Amazing work! 🎉';
    if (ratio >= 0.8) return 'Great job! You really know your stuff!';
    if (ratio >= 0.6) return 'Good effort! Keep practicing!';
    return 'Keep studying — you\'ll get there!';
  }

  Color get _scoreColor {
    final ratio = score / total;
    if (ratio >= 0.8) return Colors.green;
    if (ratio >= 0.6) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    // Build weak topics list for Option 3
    final weakCategories = categoryMisses.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Celebration image
              Center(
                child: Image.asset('assets/images/trophy.png', height: 140),
              ),
              const SizedBox(height: 20),

              // Score
              Text(
                '$score / $total',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: _scoreColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _feedbackMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 32),

              // Option 3: Smart Review Summary
              if (weakCategories.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.school, color: Colors.indigo),
                          SizedBox(width: 8),
                          Text(
                            'Smart Review Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Focus on these topics in your next study session:',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      ...weakCategories.map((entry) {
                        final total = categoryTotal[entry.key] ?? 1;
                        final missRatio = entry.value / total;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${entry.value} missed',
                                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: missRatio,
                                backgroundColor: Colors.green.shade100,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  missRatio > 0.5 ? Colors.red : Colors.orange,
                                ),
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _studyTip(entry.key),
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Play Again button
              ElevatedButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizScreen()),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Play Again', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _studyTip(String category) {
    const tips = {
      'Programming': 'Review syntax rules, data structures, and logic patterns.',
      'Linux': 'Practice common terminal commands and file permissions.',
      'DevOps': 'Study CI/CD pipelines, containers, and deployment workflows.',
      'Networking': 'Review OSI model, TCP/IP, and common protocols.',
      'Docker': 'Practice Dockerfile syntax and container orchestration concepts.',
      'SQL': 'Review JOIN types, subqueries, and normalization rules.',
    };
    return tips[category] ?? 'Review the core concepts and try practice exercises for $category.';
  }
}