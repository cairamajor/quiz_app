import 'package:flutter/material.dart';
import '../services/quiz_service.dart';
import '../models/question.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {

  late Future<List<Question>> questions;

  @override
  void initState() {
    super.initState();
    questions = QuizService.fetchQuestions();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz App")),

      body: FutureBuilder<List<Question>>(
        future: questions,

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading quiz"));
          }

          final data = snapshot.data!;

          return ListView.builder(
            itemCount: data.length,

            itemBuilder: (context, index) {

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(data[index].question),
                ),
              );
            },
          );
        },
      ),
    );
  }
}