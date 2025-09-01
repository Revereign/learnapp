import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/materi.dart';
import '../../../domain/usecases/materi/get_materi_by_level.dart';
import '../../../data/services/game_score_service.dart';
import 'dart:math';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GetMateriByLevel getMateriByLevel;
  final GameScoreService _gameScoreService = GameScoreService();
  final Random _random = Random();

  GameBloc({required this.getMateriByLevel}) : super(GameInitial()) {
    on<LoadGame>(_onLoadGame);
    on<StartNewRound>(_onStartNewRound);
    on<CheckAnswer>(_onCheckAnswer);
    on<PlayAudio>(_onPlayAudio);
  }

  /// Update game score in Firestore if the new score is higher
  Future<void> _updateGameScore(int score) async {
    try {
      // Get the current level from the state
      final currentState = state;
      if (currentState is GameLoaded) {
        // Extract level from the first materi (assuming all materi are from the same level)
        if (currentState.allMateri.isNotEmpty) {
          final level = currentState.allMateri.first.level;
          await _gameScoreService.updateGameScore(level, score);
        }
      }
    } catch (e) {
      print('Error updating game score: $e');
    }
  }

  Future<void> _onLoadGame(LoadGame event, Emitter<GameState> emit) async {
    emit(GameLoading());
    
    try {
      final materiList = await getMateriByLevel(event.level);
      if (materiList.isEmpty) {
        emit(GameError('Tidak ada materi untuk level ini'));
        return;
      }

      // Shuffle materi untuk randomisasi hanya sekali di awal
      final shuffledMateri = List<Materi>.from(materiList)..shuffle(_random);
      
      emit(GameLoaded(
        allMateri: shuffledMateri,
        remainingMateri: List<Materi>.from(shuffledMateri),
        currentQuestion: null,
        score: 0,
        totalQuestions: shuffledMateri.length,
        lives: 4, // Initialize with 4 lives
      ));
      
      // Start first round
      add(StartNewRound());
    } catch (e) {
      emit(GameError(e.toString()));
    }
  }

  void _onStartNewRound(StartNewRound event, Emitter<GameState> emit) {
    final currentState = state;
    if (currentState is GameLoaded) {
      if (currentState.remainingMateri.isEmpty) {
        // Update game score before emitting completion state
        _updateGameScore(currentState.score);
        
        emit(GameCompleted(
          score: currentState.score,
          totalQuestions: currentState.totalQuestions,
          lives: currentState.lives, // Include lives in completed state
        ));
        return;
      }

      // Select random question type (0: Hanzi, 1: Pinyin, 2: Audio)
      final questionType = _random.nextInt(3);
      // Always take the first item from remainingMateri (which was shuffled at the beginning)
      final currentMateri = currentState.remainingMateri.first;
      
      emit(currentState.copyWith(
        currentQuestion: GameQuestion(
          materi: currentMateri,
          questionType: questionType,
        ),
      ));
    }
  }

  void _onCheckAnswer(CheckAnswer event, Emitter<GameState> emit) {
    final currentState = state;
    if (currentState is GameLoaded) {
      final isCorrect = event.selectedMateri.id == currentState.currentQuestion!.materi.id;
      
      if (isCorrect) {
        // Remove correct answer from remaining materi
        final updatedRemaining = List<Materi>.from(currentState.remainingMateri)
          ..removeWhere((m) => m.id == event.selectedMateri.id);
        
        emit(currentState.copyWith(
          remainingMateri: updatedRemaining,
          score: currentState.score + 1,
          lastAnswer: GameAnswer(
            isCorrect: true,
            selectedMateri: event.selectedMateri,
            correctMateri: currentState.currentQuestion!.materi,
          ),
        ));
        
        // Start next round after a short delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          add(StartNewRound());
        });
      } else {
        // Reduce life when answer is wrong
        final newLives = currentState.lives - 1;
        
        if (newLives <= 0) {
          // Game over when lives are exhausted
          // Update game score before emitting game over state
          _updateGameScore(currentState.score);
          
          emit(GameOver(
            score: currentState.score,
            totalQuestions: currentState.totalQuestions,
          ));
        } else {
          emit(currentState.copyWith(
            lives: newLives,
            lastAnswer: GameAnswer(
              isCorrect: false,
              selectedMateri: event.selectedMateri,
              correctMateri: currentState.currentQuestion!.materi,
            ),
          ));
        }
      }
    }
  }

  void _onPlayAudio(PlayAudio event, Emitter<GameState> emit) {
    // Audio will be handled by the UI layer
    // This event is just for tracking
  }
} 