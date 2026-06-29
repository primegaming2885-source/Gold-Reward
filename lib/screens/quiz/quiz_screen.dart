import 'package:flutter/material.dart';
import '../../models/quiz_model.dart';
import '../../services/coin_service.dart';
import '../../services/quiz_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/popunder_ad_widget.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin {
  final QuizService _quizService = QuizService();
  final CoinService _coinService = CoinService();

  QuizQuestion? _currentQuestion;
  int? _selectedAnswer;
  bool _answered = false;
  int _sessionCoins = 0;
  int _questionsAnswered = 0;
  int _correctCount = 0;
  bool _quizEnded = false;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04)
        .animate(_pulseCtrl);
    _nextQuestion();
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestion = _quizService.generateQuestion();
      _selectedAnswer = null;
      _answered = false;
    });
  }

  Future<void> _answer(int option) async {
    if (_answered) return;
    final isCorrect =
        option == _currentQuestion!.correctAnswer;
    setState(() {
      _selectedAnswer = option;
      _answered = true;
      _questionsAnswered++;
      if (isCorrect) {
        _correctCount++;
        _sessionCoins += AppConstants.quizCorrectCoins;
      }
    });
    await _coinService.addQuizCoins(
        _currentQuestion!.question, isCorrect);
    await Future.delayed(
        const Duration(milliseconds: 1000));
    if (!mounted) return;
    await PopunderAdHelper.show(context);
    if (mounted) _nextQuestion();
  }

  Future<void> _endQuiz() async {
    setState(() => _quizEnded = true);
    await PopunderAdHelper.show(context);
    if (!mounted) return;
    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                  color: AppTheme.goldPrimary,
                  shape: BoxShape.circle),
              child: const Icon(Icons.emoji_events,
                  size: 44, color: Colors.white),
            ),
            const SizedBox(height: 14),
            const Text('Quiz Complete!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            _resultRow('Questions Answered',
                '$_questionsAnswered'),
            _resultRow(
                'Correct Answers', '$_correctCount'),
            _resultRow(
                'Coins Earned', '+$_sessionCoins'),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: const Text('Exit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _quizEnded = false;
                      _sessionCoins = 0;
                      _questionsAnswered = 0;
                      _correctCount = 0;
                    });
                    _nextQuestion();
                  },
                  child: const Text('Play Again'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
        ],
      ),
    );
  }

  Color _optionColor(int option) {
    if (!_answered)
      return Theme.of(context).colorScheme.surface;
    if (option == _currentQuestion!.correctAnswer)
      return AppTheme.success;
    if (option == _selectedAnswer)
      return AppTheme.error;
    return Theme.of(context).colorScheme.surface;
  }

  Color _optionTextColor(int option) {
    if (!_answered)
      return Theme.of(context).colorScheme.onSurface;
    if (option == _currentQuestion!.correctAnswer ||
        option == _selectedAnswer) return Colors.white;
    return Theme.of(context).colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final q = _currentQuestion;
    if (q == null) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Quiz'),
        actions: [
          if (_sessionCoins > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        Colors.white.withOpacity(0.2),
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Text('+$_sessionCoins',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          TextButton(
            onPressed: _quizEnded ? null : _endQuiz,
            child: const Text('End',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Question #${_questionsAnswered + 1}',
                    style: const TextStyle(
                        color: Colors.grey)),
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 15,
                        color: AppTheme.success),
                    const SizedBox(width: 4),
                    Text('$_correctCount correct',
                        style: const TextStyle(
                            color: AppTheme.success,
                            fontSize: 13)),
                    const SizedBox(width: 12),
                    const Icon(Icons.monetization_on,
                        size: 15,
                        color: AppTheme.goldDark),
                    const SizedBox(width: 4),
                    Text('$_sessionCoins coins',
                        style: const TextStyle(
                            color: AppTheme.goldDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 36, horizontal: 24),
                decoration: AppTheme.goldGradientCard(),
                child: Column(
                  children: [
                    const Text('What is',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(q.question,
                        style: const TextStyle(
                            fontSize: 54,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -2)),
                    const Text('= ?',
                        style: TextStyle(
                            fontSize: 28,
                            color: Colors.white70,
                            fontWeight:
                                FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Choose the correct answer:',
                style: TextStyle(
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: q.options.map((opt) {
                return GestureDetector(
                  onTap: () => _answer(opt),
                  child: AnimatedContainer(
                    duration: const Duration(
                        milliseconds: 280),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _optionColor(opt),
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color: _answered
                            ? _optionColor(opt)
                            : AppTheme.goldPrimary
                                .withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Text('$opt',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color:
                                _optionTextColor(opt))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (_answered)
              AnimatedContainer(
                duration:
                    const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: (_selectedAnswer ==
                              q.correctAnswer
                          ? AppTheme.success
                          : AppTheme.error)
                      .withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        _selectedAnswer == q.correctAnswer
                            ? AppTheme.success
                            : AppTheme.error,
                  ),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedAnswer == q.correctAnswer
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: _selectedAnswer ==
                              q.correctAnswer
                          ? AppTheme.success
                          : AppTheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedAnswer == q.correctAnswer
                          ? '+${AppConstants.quizCorrectCoins} Coin! 🎉'
                          : 'Wrong! Answer: ${q.correctAnswer}',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _selectedAnswer ==
                                  q.correctAnswer
                              ? AppTheme.success
                              : AppTheme.error),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _quizEnded ? null : _endQuiz,
              icon: const Icon(
                  Icons.stop_circle_outlined),
              label: const Text(
                  'End Quiz & See Results'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey,
                side: const BorderSide(
                    color: Colors.grey),
                padding: const EdgeInsets.symmetric(
                    vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }
}
