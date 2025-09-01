part of 'find_object_bloc.dart';

abstract class Level3FindObjectState extends Equatable {
  const Level3FindObjectState();

  @override
  List<Object?> get props => [];
}

class Level3FindObjectInitial extends Level3FindObjectState {}

class Level3GameLoading extends Level3FindObjectState {}

class Level3GameLoaded extends Level3FindObjectState {
  final List<Materi> allMateri;
  final List<Level3GameObject> gameObjects;
  final Level3Question? currentQuestion;
  final Level3Answer? lastAnswer;
  final int score;
  final int totalQuestions;
  final int lives;
  final List<String> answeredQuestions;
  final int level;

  const Level3GameLoaded({
    required this.allMateri,
    required this.gameObjects,
    this.currentQuestion,
    this.lastAnswer,
    required this.score,
    required this.totalQuestions,
    required this.lives,
    required this.answeredQuestions,
    required this.level,
  });

  Level3GameLoaded copyWith({
    List<Materi>? allMateri,
    List<Level3GameObject>? gameObjects,
    Level3Question? currentQuestion,
    Level3Answer? lastAnswer,
    int? score,
    int? totalQuestions,
    int? lives,
    List<String>? answeredQuestions,
    int? level,
  }) {
    return Level3GameLoaded(
      allMateri: allMateri ?? this.allMateri,
      gameObjects: gameObjects ?? this.gameObjects,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      lastAnswer: lastAnswer ?? this.lastAnswer,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      lives: lives ?? this.lives,
      answeredQuestions: answeredQuestions ?? this.answeredQuestions,
      level: level ?? this.level,
    );
  }

  @override
  List<Object?> get props => [
    allMateri,
    gameObjects,
    currentQuestion,
    lastAnswer,
    score,
    totalQuestions,
    lives,
    answeredQuestions,
    level,
  ];
}

class Level3GameCompleted extends Level3FindObjectState {
  final int score;
  final int totalQuestions;
  final int lives;

  const Level3GameCompleted({
    required this.score,
    required this.totalQuestions,
    required this.lives,
  });

  @override
  List<Object> get props => [score, totalQuestions, lives];
}

class Level3GameOver extends Level3FindObjectState {
  final int score;
  final int totalQuestions;

  const Level3GameOver({
    required this.score,
    required this.totalQuestions,
  });

  @override
  List<Object> get props => [score, totalQuestions];
}

class Level3GameError extends Level3FindObjectState {
  final String message;

  const Level3GameError(this.message);

  @override
  List<Object> get props => [message];
}

class Level3Question {
  final Materi materi;
  final int questionType; // 0: Hanzi, 1: Pinyin, 2: Audio

  const Level3Question({
    required this.materi,
    required this.questionType,
  });
}

class Level3Answer {
  final bool isCorrect;
  final Materi selectedMateri;
  final Materi correctMateri;

  const Level3Answer({
    required this.isCorrect,
    required this.selectedMateri,
    required this.correctMateri,
  });
}

class Level3GameObject {
  final Materi materi;
  final Offset position;

  const Level3GameObject({
    required this.materi,
    required this.position,
  });
}
