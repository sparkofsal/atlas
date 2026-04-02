import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_beliefs.dart';
import '../services/app_state.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Random _random = Random();

  late Map<String, dynamic> _currentQuestion;
  String? _selectedAnswer;
  bool _answered = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadNewQuestion();
  }

  void _loadNewQuestion() {
    final belief = mockBeliefs[_random.nextInt(mockBeliefs.length)];
    final correctAnswer = belief.countryName;

    final allCountryNames = mockBeliefs
        .map((b) => b.countryName)
        .toSet()
        .where((name) => name != correctAnswer)
        .toList()
      ..shuffle();

    final options = <String>[
      correctAnswer,
      ...allCountryNames.take(3),
    ]..shuffle();

    setState(() {
      _currentQuestion = {
        'beliefTitle': belief.title,
        'beliefDescription': belief.description,
        'correctAnswer': correctAnswer,
        'options': options,
      };
      _selectedAnswer = null;
      _answered = false;
      _isCorrect = false;
    });
  }

  Future<void> _selectAnswer(String answer) async {
    if (_answered) return;

    final isCorrect = answer == _currentQuestion['correctAnswer'];

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      await Provider.of<AppState>(context, listen: false).addXp(10);
    }
  }

  Color? _getButtonColor(String option) {
    if (!_answered) return null;

    if (option == _currentQuestion['correctAnswer']) {
      return Colors.green.shade200;
    }

    if (option == _selectedAnswer &&
        option != _currentQuestion['correctAnswer']) {
      return Colors.red.shade200;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final options = _currentQuestion['options'] as List<String>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Which country is this belief from?',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentQuestion['beliefTitle'] as String,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(_currentQuestion['beliefDescription'] as String),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getButtonColor(option),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _selectAnswer(option),
                    child: Text(option),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_answered)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        _isCorrect ? 'Correct! +10 XP' : 'Not quite',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Answer: ${_currentQuestion['correctAnswer']}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadNewQuestion,
                        child: const Text('Next Question'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}