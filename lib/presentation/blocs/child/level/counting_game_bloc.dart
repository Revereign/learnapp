import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/materi.dart';
import '../../../../domain/usecases/materi/get_materi_by_level.dart';
import '../../../../data/services/game_score_service.dart';

// Events
abstract class CountingGameEvent extends Equatable {
  const CountingGameEvent();

  @override
  List<Object?> get props => [];
}

class LoadCountingGameEvent extends CountingGameEvent {
  final int level;
  
  const LoadCountingGameEvent(this.level);
  
  @override
  List<Object?> get props => [level];
}

class AnswerQuestionEvent extends CountingGameEvent {
  final int questionIndex;
  final List<String> selectedFruits;
  
  const AnswerQuestionEvent({
    required this.questionIndex,
    required this.selectedFruits,
  });
  
  @override
  List<Object?> get props => [questionIndex, selectedFruits];
}

class NextQuestionEvent extends CountingGameEvent {}

class ResetGameEvent extends CountingGameEvent {}

// States
abstract class CountingGameState extends Equatable {
  const CountingGameState();

  @override
  List<Object?> get props => [];
}

class CountingGameInitial extends CountingGameState {}

class CountingGameLoading extends CountingGameState {}

class CountingGameLoaded extends CountingGameState {
  final List<CountingQuestion> questions;
  final List<Materi> availableFruits;
  final int currentQuestionIndex;
  final int score;
  final bool isGameComplete;
  
  const CountingGameLoaded({
    required this.questions,
    required this.availableFruits,
    required this.currentQuestionIndex,
    required this.score,
    required this.isGameComplete,
  });
  
  @override
  List<Object?> get props => [
    questions,
    availableFruits,
    currentQuestionIndex,
    score,
    isGameComplete,
  ];
}

class CountingGameError extends CountingGameState {
  final String message;
  
  const CountingGameError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Models
class CountingQuestion {
  final int questionIndex;
  final String questionText;
  final String correctFruit;
  final int correctCount;
  final List<String> options;
  final bool isAnswered;
  final bool isCorrect;
  
  CountingQuestion({
    required this.questionIndex,
    required this.questionText,
    required this.correctFruit,
    required this.correctCount,
    required this.options,
    this.isAnswered = false,
    this.isCorrect = false,
  });
  
  CountingQuestion copyWith({
    int? questionIndex,
    String? questionText,
    String? correctFruit,
    int? correctCount,
    List<String>? options,
    bool? isAnswered,
    bool? isCorrect,
  }) {
    return CountingQuestion(
      questionIndex: questionIndex ?? this.questionIndex,
      questionText: questionText ?? this.questionText,
      correctFruit: correctFruit ?? this.correctFruit,
      correctCount: correctCount ?? this.correctCount,
      options: options ?? this.options,
      isAnswered: isAnswered ?? this.isAnswered,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}

// Bloc
class CountingGameBloc extends Bloc<CountingGameEvent, CountingGameState> {
  final GetMateriByLevel getMateriByLevel;
  final GameScoreService _gameScoreService = GameScoreService();
  
  CountingGameBloc({
    required this.getMateriByLevel,
  }) : super(CountingGameInitial()) {
    on<LoadCountingGameEvent>(_onLoadCountingGame);
    on<AnswerQuestionEvent>(_onAnswerQuestion);
    on<NextQuestionEvent>(_onNextQuestion);
    on<ResetGameEvent>(_onResetGame);
  }
  
  Future<void> _onLoadCountingGame(
    LoadCountingGameEvent event,
    Emitter<CountingGameState> emit,
  ) async {
    emit(CountingGameLoading());
    
    try {
      // Load materi from Firebase
      final materiList = await getMateriByLevel(event.level);
      
      print('=== BLOC DEBUG ===');
      print('Level: ${event.level}');
      print('Materi loaded: ${materiList.length}');
      print('First materi: ${materiList.isNotEmpty ? materiList.first.arti : "None"}');
      print('==================');
      
      if (materiList.isEmpty) {
        emit(const CountingGameError('Tidak ada materi untuk level ini'));
        return;
      }
      
      // Generate 10 questions
      final questions = _generateQuestions(materiList);
      
      print('Questions generated: ${questions.length}');
      if (questions.isNotEmpty) {
        print('First question: "${questions.first.questionText}"');
        print('First question length: ${questions.first.questionText.length}');
        print('First question isEmpty: ${questions.first.questionText.isEmpty}');
        print('First question correctFruit: "${questions.first.correctFruit}"');
        print('First question correctCount: ${questions.first.correctCount}');
      } else {
        print('No questions generated!');
      }
      print('==================');
      
      emit(CountingGameLoaded(
        questions: questions,
        availableFruits: materiList,
        currentQuestionIndex: 0,
        score: 0,
        isGameComplete: false,
      ));
    } catch (e) {
      emit(CountingGameError(e.toString()));
    }
  }
  
  void _onAnswerQuestion(
    AnswerQuestionEvent event,
    Emitter<CountingGameState> emit,
  ) {
    if (state is CountingGameLoaded) {
      final currentState = state as CountingGameLoaded;
      final currentQuestion = currentState.questions[event.questionIndex];
      
      // Check if answer is correct
      final isCorrect = _checkAnswer(
        currentQuestion,
        event.selectedFruits,
      );
      
      // Update question state
      final updatedQuestions = List<CountingQuestion>.from(currentState.questions);
      updatedQuestions[event.questionIndex] = currentQuestion.copyWith(
        isAnswered: true,
        isCorrect: isCorrect,
      );
      
      // Calculate new score
      final newScore = isCorrect ? currentState.score + 1 : currentState.score;
      
      // Check if game is complete
      final isGameComplete = event.questionIndex == 9; // Last question (0-9)
      
      // Update game score if game is complete
      if (isGameComplete) {
        _updateGameScore(newScore, currentState.availableFruits.first.level);
      }
      
      emit(CountingGameLoaded(
        questions: updatedQuestions,
        availableFruits: currentState.availableFruits,
        currentQuestionIndex: currentState.currentQuestionIndex,
        score: newScore,
        isGameComplete: isGameComplete,
      ));
    }
  }
  
  void _onNextQuestion(
    NextQuestionEvent event,
    Emitter<CountingGameState> emit,
  ) {
    if (state is CountingGameLoaded) {
      final currentState = state as CountingGameLoaded;
      
      if (currentState.currentQuestionIndex < 9) {
        emit(CountingGameLoaded(
          questions: currentState.questions,
          availableFruits: currentState.availableFruits,
          currentQuestionIndex: currentState.currentQuestionIndex + 1,
          score: currentState.score,
          isGameComplete: currentState.isGameComplete,
        ));
      }
    }
  }
  
  void _onResetGame(
    ResetGameEvent event,
    Emitter<CountingGameState> emit,
  ) {
    emit(CountingGameInitial());
  }

  /// Update game score in Firestore if the new score is higher
  Future<void> _updateGameScore(int score, int level) async {
    try {
      await _gameScoreService.updateGameScore(level, score);
    } catch (e) {
      print('Error updating game score: $e');
    }
  }
  
  List<CountingQuestion> _generateQuestions(List<Materi> materiList) {
    final questions = <CountingQuestion>[];
    final random = Random();
    
    for (int i = 0; i < 10; i++) {
      // Select random fruits for this question
      final shuffledMateri = List<Materi>.from(materiList);
      shuffledMateri.shuffle(random);
      
      // Take first 3 fruits for options
      final options = shuffledMateri.take(3).map((m) => m.arti).toList();
      
      // Select correct fruit and count
      final correctFruit = options[0]; // First fruit is correct
      
      // Generate mathematical operation (addition or subtraction)
      final operation = random.nextBool() ? '+' : '-';
      int firstNumber, secondNumber, correctCount;
      
      if (operation == '+') {
        // Addition: ensure result doesn't exceed 10
        firstNumber = random.nextInt(5) + 1; // 1-5
        secondNumber = random.nextInt(5) + 1; // 1-5
        correctCount = firstNumber + secondNumber;
        // Ensure result doesn't exceed 10
        if (correctCount > 10) {
          correctCount = 10;
          firstNumber = 5;
          secondNumber = 5;
        }
      } else {
        // Subtraction: ensure positive result
        firstNumber = random.nextInt(8) + 3; // 3-10
        secondNumber = random.nextInt(firstNumber - 1) + 1; // 1 to (firstNumber-1)
        correctCount = firstNumber - secondNumber;
      }
      
                  // Generate question text with mathematical operation and Hanzhi character
            final questionText = '$firstNumber $operation $secondNumber ${shuffledMateri[0].kosakata}';
      
      print('Generated question $i: "$questionText"');
      
      questions.add(CountingQuestion(
        questionIndex: i,
        questionText: questionText,
        correctFruit: correctFruit,
        correctCount: correctCount,
        options: options,
      ));
    }
    
    return questions;
  }
  
  bool _checkAnswer(CountingQuestion question, List<String> selectedFruits) {
    // Check if correct fruit is selected
    if (!selectedFruits.contains(question.correctFruit)) {
      return false;
    }
    
    // Check if correct count
    if (selectedFruits.length != question.correctCount) {
      return false;
    }
    
    // Check if all selected fruits are correct (no wrong fruits)
    for (final fruit in selectedFruits) {
      if (fruit != question.correctFruit) {
        return false;
      }
    }
    
    return true;
  }
}
