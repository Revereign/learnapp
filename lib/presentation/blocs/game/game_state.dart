part of 'game_bloc.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameLoaded extends GameState {
  final List<Materi> allMateri;
  final List<Materi> remainingMateri;
  final GameQuestion? currentQuestion;
  final GameAnswer? lastAnswer;
  final int score;
  final int totalQuestions;
  final int lives; // Add lives field

  const GameLoaded({
    required this.allMateri,
    required this.remainingMateri,
    this.currentQuestion,
    this.lastAnswer,
    required this.score,
    required this.totalQuestions,
    required this.lives, // Add lives parameter
  });

  GameLoaded copyWith({
    List<Materi>? allMateri,
    List<Materi>? remainingMateri,
    GameQuestion? currentQuestion,
    GameAnswer? lastAnswer,
    int? score,
    int? totalQuestions,
    int? lives, // Add lives parameter
  }) {
    return GameLoaded(
      allMateri: allMateri ?? this.allMateri,
      remainingMateri: remainingMateri ?? this.remainingMateri,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      lastAnswer: lastAnswer ?? this.lastAnswer,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      lives: lives ?? this.lives, // Add lives
    );
  }

  @override
  List<Object?> get props => [allMateri, remainingMateri, currentQuestion, lastAnswer, score, totalQuestions, lives]; // Add lives to props
}

class GameCompleted extends GameState {
  final int score;
  final int totalQuestions;
  final int lives; // Add lives field

  const GameCompleted({
    required this.score,
    required this.totalQuestions,
    required this.lives, // Add lives parameter
  });

  @override
  List<Object?> get props => [score, totalQuestions, lives]; // Add lives to props
}

class GameError extends GameState {
  final String message;

  const GameError(this.message);

  @override
  List<Object?> get props => [message];
}

class GameOver extends GameState {
  final int score;
  final int totalQuestions;

  const GameOver({
    required this.score,
    required this.totalQuestions,
  });

  @override
  List<Object?> get props => [score, totalQuestions];
}

class GameQuestion {
  final Materi materi;
  final int questionType; // 0: Hanzi, 1: Pinyin, 2: Audio

  const GameQuestion({
    required this.materi,
    required this.questionType,
  });
}

class GameAnswer {
  final bool isCorrect;
  final Materi selectedMateri;
  final Materi correctMateri;

  const GameAnswer({
    required this.isCorrect,
    required this.selectedMateri,
    required this.correctMateri,
  });
} 