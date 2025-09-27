part of 'find_object_bloc.dart';

abstract class FindObjectState extends Equatable {
  const FindObjectState();

  @override
  List<Object?> get props => [];
}

class Level3FindObjectInitial extends FindObjectState {}

class Level3GameLoading extends FindObjectState {}

class GameLoaded extends FindObjectState {
  final List<Materi> allMateri;
  final List<GameObject> gameObjects;
  final Level3Question? currentQuestion;
  final LevelAnswer? lastAnswer;
  final int score;
  final int totalQuestions;
  final int lives;
  final List<String> answeredQuestions;
  final int level;

  const GameLoaded({
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

  GameLoaded copyWith({
    List<Materi>? allMateri,
    List<GameObject>? gameObjects,
    Level3Question? currentQuestion,
    LevelAnswer? lastAnswer,
    int? score,
    int? totalQuestions,
    int? lives,
    List<String>? answeredQuestions,
    int? level,
  }) {
    return GameLoaded(
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

class Level3GameCompleted extends FindObjectState {
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

class GameOver extends FindObjectState {
  final int score;
  final int totalQuestions;

  const GameOver({
    required this.score,
    required this.totalQuestions,
  });

  @override
  List<Object> get props => [score, totalQuestions];
}

class Level3GameError extends FindObjectState {
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

class LevelAnswer {
  final bool isCorrect;
  final Materi selectedMateri;
  final Materi correctMateri;

  const LevelAnswer({
    required this.isCorrect,
    required this.selectedMateri,
    required this.correctMateri,
  });
}

class GameObject {
  final Materi materi;
  final Offset position;

  const GameObject({
    required this.materi,
    required this.position,
  });
}
