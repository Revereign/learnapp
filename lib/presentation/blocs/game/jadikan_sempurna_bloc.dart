import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/materi.dart';
import '../../../data/repositories/materi_repository_impl.dart';

// Events
abstract class JadikanSempurnaEvent extends Equatable {
  const JadikanSempurnaEvent();

  @override
  List<Object?> get props => [];
}

class LoadJadikanSempurnaGame extends JadikanSempurnaEvent {
  final int level;
  const LoadJadikanSempurnaGame(this.level);

  @override
  List<Object?> get props => [level];
}

class StartNewQuestion extends JadikanSempurnaEvent {}

class CheckReadingAnswer extends JadikanSempurnaEvent {
  final String recognizedText;
  final String correctAnswer;
  const CheckReadingAnswer(this.recognizedText, this.correctAnswer);

  @override
  List<Object?> get props => [recognizedText, correctAnswer];
}

class CheckStrokeOrderAnswer extends JadikanSempurnaEvent {
  final int mistakes;
  const CheckStrokeOrderAnswer(this.mistakes);

  @override
  List<Object?> get props => [mistakes];
}

class ResetGame extends JadikanSempurnaEvent {}

// States
abstract class JadikanSempurnaState extends Equatable {
  const JadikanSempurnaState();

  @override
  List<Object?> get props => [];
}

class JadikanSempurnaInitial extends JadikanSempurnaState {}

class JadikanSempurnaLoading extends JadikanSempurnaState {}

class JadikanSempurnaLoaded extends JadikanSempurnaState {
  final List<JadikanSempurnaQuestion> questions;
  final int currentQuestionIndex;
  final int score;
  final int totalQuestions;
  final int plantGrowthStage;
  final bool isGameCompleted;
  final bool isGameOver;
  final JadikanSempurnaQuestion currentQuestion;
  final int readingAttempts;
  final int strokeOrderAttempts;

  const JadikanSempurnaLoaded({
    required this.questions,
    required this.currentQuestionIndex,
    required this.score,
    required this.totalQuestions,
    required this.plantGrowthStage,
    required this.isGameCompleted,
    required this.isGameOver,
    required this.currentQuestion,
    required this.readingAttempts,
    required this.strokeOrderAttempts,
  });

  @override
  List<Object?> get props => [
        questions,
        currentQuestionIndex,
        score,
        totalQuestions,
        plantGrowthStage,
        isGameCompleted,
        isGameOver,
        currentQuestion,
        readingAttempts,
        strokeOrderAttempts,
      ];

  JadikanSempurnaLoaded copyWith({
    List<JadikanSempurnaQuestion>? questions,
    int? currentQuestionIndex,
    int? score,
    int? totalQuestions,
    int? plantGrowthStage,
    bool? isGameCompleted,
    bool? isGameOver,
    JadikanSempurnaQuestion? currentQuestion,
    int? readingAttempts,
    int? strokeOrderAttempts,
  }) {
    return JadikanSempurnaLoaded(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      plantGrowthStage: plantGrowthStage ?? this.plantGrowthStage,
      isGameCompleted: isGameCompleted ?? this.isGameCompleted,
      isGameOver: isGameOver ?? this.isGameOver,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      readingAttempts: readingAttempts ?? this.readingAttempts,
      strokeOrderAttempts: strokeOrderAttempts ?? this.strokeOrderAttempts,
    );
  }
}

class JadikanSempurnaError extends JadikanSempurnaState {
  final String message;
  const JadikanSempurnaError(this.message);

  @override
  List<Object?> get props => [message];
}

// Models
class JadikanSempurnaQuestion {
  final Materi materi;
  final QuestionType type;
  final String? selectedCharacter; // For stroke order questions

  JadikanSempurnaQuestion({
    required this.materi,
    required this.type,
    this.selectedCharacter,
  });
}

enum QuestionType { reading, strokeOrder }

// BLOC
class JadikanSempurnaBloc extends Bloc<JadikanSempurnaEvent, JadikanSempurnaState> {
  final MateriRepositoryImpl _materiRepository;
  final Random _random = Random();

  JadikanSempurnaBloc(this._materiRepository) : super(JadikanSempurnaInitial()) {
    on<LoadJadikanSempurnaGame>(_onLoadGame);
    on<StartNewQuestion>(_onStartNewQuestion);
    on<CheckReadingAnswer>(_onCheckReadingAnswer);
    on<CheckStrokeOrderAnswer>(_onCheckStrokeOrderAnswer);
    on<ResetGame>(_onResetGame);
  }

  Future<void> _onLoadGame(
    LoadJadikanSempurnaGame event,
    Emitter<JadikanSempurnaState> emit,
  ) async {
    try {
      emit(JadikanSempurnaLoading());

      // Load materi from level 4
      final materiList = await _materiRepository.getMateriByLevel(4);
      
      if (materiList.isEmpty) {
        emit(const JadikanSempurnaError('Tidak ada materi untuk level 4'));
        return;
      }

      // Create 8 questions (mix of reading and stroke order)
      final questions = <JadikanSempurnaQuestion>[];
      final random = Random();
      
      // Ensure we have enough materi for 8 questions
      final shuffledMateri = List.from(materiList)..shuffle(random);
      
      for (int i = 0; i < 8; i++) {
        if (i < shuffledMateri.length) {
          final materi = shuffledMateri[i];
          final questionType = random.nextBool() ? QuestionType.reading : QuestionType.strokeOrder;
          
          if (questionType == QuestionType.strokeOrder) {
            // For stroke order, select one character if the word has multiple characters
            final characters = materi.kosakata.split('');
            if (characters.length > 1) {
              final selectedChar = characters[random.nextInt(characters.length)];
              questions.add(JadikanSempurnaQuestion(
                materi: materi,
                type: questionType,
                selectedCharacter: selectedChar,
              ));
            } else {
              questions.add(JadikanSempurnaQuestion(
                materi: materi,
                type: questionType,
              ));
            }
          } else {
            questions.add(JadikanSempurnaQuestion(
              materi: materi,
              type: questionType,
            ));
          }
        }
      }

      // Shuffle questions to randomize order
      questions.shuffle(random);

      emit(JadikanSempurnaLoaded(
        questions: questions,
        currentQuestionIndex: 0,
        score: 0,
        totalQuestions: 8,
        plantGrowthStage: 0,
        isGameCompleted: false,
        isGameOver: false,
        currentQuestion: questions[0],
        readingAttempts: 0,
        strokeOrderAttempts: 0,
      ));
    } catch (e) {
      emit(JadikanSempurnaError('Gagal memuat game: $e'));
    }
  }

  void _onStartNewQuestion(
    StartNewQuestion event,
    Emitter<JadikanSempurnaState> emit,
  ) {
    if (state is JadikanSempurnaLoaded) {
      final currentState = state as JadikanSempurnaLoaded;
      
      if (currentState.currentQuestionIndex < currentState.questions.length - 1) {
        final nextIndex = currentState.currentQuestionIndex + 1;
        final nextQuestion = currentState.questions[nextIndex];
        
        emit(currentState.copyWith(
          currentQuestionIndex: nextIndex,
          currentQuestion: nextQuestion,
          readingAttempts: 0,
          strokeOrderAttempts: 0,
        ));
      } else {
        // Game completed
        emit(currentState.copyWith(
          isGameCompleted: true,
        ));
      }
    }
  }

  void _onCheckReadingAnswer(
    CheckReadingAnswer event,
    Emitter<JadikanSempurnaState> emit,
  ) {
    if (state is JadikanSempurnaLoaded) {
      final currentState = state as JadikanSempurnaLoaded;
      
      // Check pronunciation against Mandarin (kosakata) - not arti
      final isCorrect = event.recognizedText.toLowerCase().contains(
            currentState.currentQuestion.materi.kosakata.toLowerCase(),
          );

      if (isCorrect) {
        // Correct answer
        final newScore = currentState.score + 1;
        final newPlantStage = newScore; // Direct: 1 correct = stage 1, 2 correct = stage 2, etc.
        
        emit(currentState.copyWith(
          score: newScore,
          plantGrowthStage: newPlantStage,
          readingAttempts: 0,
        ));
        
        // Check if player wins immediately (plant stage 5 = 100%)
        if (newPlantStage >= 5) {
          emit(currentState.copyWith(
            score: newScore,
            plantGrowthStage: newPlantStage,
            isGameCompleted: true,
            readingAttempts: 0,
          ));
        } else {
          // Move to next question
          add(StartNewQuestion());
        }
      } else {
        // Wrong answer
        final newAttempts = currentState.readingAttempts + 1;
        
        if (newAttempts >= 2) {
          // Max attempts reached, move to next question
          add(StartNewQuestion());
        } else {
          // Still have attempts
          emit(currentState.copyWith(
            readingAttempts: newAttempts,
          ));
        }
      }
    }
  }

  void _onCheckStrokeOrderAnswer(
      CheckStrokeOrderAnswer event,
      Emitter<JadikanSempurnaState> emit,
      ) {
    if (state is JadikanSempurnaLoaded) {
      final currentState = state as JadikanSempurnaLoaded;

      // Changed from <= 2 to <= 1 to match reading question standards
      if (event.mistakes <= 1) { // Consider correct if 1 or fewer mistakes
        // Correct answer
        final newScore = currentState.score + 1;
        final newPlantStage = newScore; // Direct: 1 correct = stage 1, 2 correct = stage 2, etc.

        emit(currentState.copyWith(
          score: newScore,
          plantGrowthStage: newPlantStage,
          strokeOrderAttempts: 0,
        ));

        // Check if player wins immediately (plant stage 5 = 100%)
        if (newPlantStage >= 5) {
          emit(currentState.copyWith(
            score: newScore,
            plantGrowthStage: newPlantStage,
            isGameCompleted: true,
            strokeOrderAttempts: 0,
          ));
        } else {
          // Move to next question
          add(StartNewQuestion());
        }
      } else {
        // Wrong answer (too many mistakes)
        final newAttempts = currentState.strokeOrderAttempts + 1;

        if (newAttempts >= 2) {
          // Max attempts reached, move to next question
          add(StartNewQuestion());
        } else {
          // Still have attempts
          emit(currentState.copyWith(
            strokeOrderAttempts: newAttempts,
          ));
        }
      }
    }
  }

  void _onResetGame(
    ResetGame event,
    Emitter<JadikanSempurnaState> emit,
  ) {
    emit(JadikanSempurnaInitial());
  }
}
