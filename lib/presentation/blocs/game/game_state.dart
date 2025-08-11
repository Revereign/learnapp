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

  const GameLoaded({
    required this.allMateri,
    required this.remainingMateri,
    this.currentQuestion,
    this.lastAnswer,
    required this.score,
    required this.totalQuestions,
  });

  GameLoaded copyWith({
    List<Materi>? allMateri,
    List<Materi>? remainingMateri,
    GameQuestion? currentQuestion,
    GameAnswer? lastAnswer,
    int? score,
    int? totalQuestions,
  }) {
    return GameLoaded(
      allMateri: allMateri ?? this.allMateri,
      remainingMateri: remainingMateri ?? this.remainingMateri,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      lastAnswer: lastAnswer ?? this.lastAnswer,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
    );
  }

  @override
  List<Object?> get props => [allMateri, remainingMateri, currentQuestion, lastAnswer, score, totalQuestions];
}

class GameCompleted extends GameState {
  final int score;
  final int totalQuestions;

  const GameCompleted({
    required this.score,
    required this.totalQuestions,
  });

  @override
  List<Object?> get props => [score, totalQuestions];
}

class GameError extends GameState {
  final String message;

  const GameError(this.message);

  @override
  List<Object?> get props => [message];
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