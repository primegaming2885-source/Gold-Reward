import 'dart:math';
import '../models/quiz_model.dart';

class QuizService {
  final Random _random = Random();

  QuizQuestion generateQuestion() {
    final operators = ['+', '-'];
    final op = operators[_random.nextInt(operators.length)];

    int num1, num2, answer;

    if (op == '+') {
      num1 = _random.nextInt(50) + 1;
      num2 = _random.nextInt(50) + 1;
      answer = num1 + num2;
    } else {
      num1 = _random.nextInt(50) + 10;
      num2 = _random.nextInt(num1) + 1;
      answer = num1 - num2;
    }

    final options = _generateOptions(answer);

    return QuizQuestion(
      num1: num1,
      num2: num2,
      operator: op,
      correctAnswer: answer,
      options: options,
    );
  }

  List<int> _generateOptions(int correct) {
    final Set<int> options = {correct};
    while (options.length < 4) {
      int wrong = correct + (_random.nextInt(20) - 10);
      if (wrong != correct && wrong > 0) {
        options.add(wrong);
      }
    }
    final list = options.toList()..shuffle(_random);
    return list;
  }
}
