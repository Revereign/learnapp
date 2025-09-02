import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/materi.dart';
import '../../../domain/usecases/materi/get_materi_by_level.dart';
import '../../../domain/usecases/auth/check_badge_achievements.dart';
import '../../../data/services/game_score_service.dart';
import 'dart:math';

part 'find_object_event.dart';
part 'find_object_state.dart';

class Level3FindObjectBloc extends Bloc<Level3FindObjectEvent, Level3FindObjectState> {
  final GetMateriByLevel getMateriByLevel;
  final GameScoreService _gameScoreService = GameScoreService();
  final CheckBadgeAchievements _checkBadgeAchievements = CheckBadgeAchievements();
  final Random _random = Random();

  Level3FindObjectBloc({required this.getMateriByLevel}) : super(Level3FindObjectInitial()) {
    on<LoadLevel3Game>(_onLoadLevel3Game);
    on<StartLevel3NewRound>(_onStartLevel3NewRound);
    on<CheckLevel3Answer>(_onCheckLevel3Answer);
  }

  Future<void> _onLoadLevel3Game(LoadLevel3Game event, Emitter<Level3FindObjectState> emit) async {
    emit(Level3GameLoading());
    
    try {
      final materiList = await getMateriByLevel(event.level);
      if (materiList.isEmpty) {
        emit(Level3GameError('Tidak ada materi untuk level ini'));
        return;
      }

      // Shuffle materi untuk randomisasi
      final shuffledMateri = List<Materi>.from(materiList)..shuffle(_random);
      
      // Take first 7 materi for questions
      final questionMateri = shuffledMateri.take(7).toList();
      
      // Take 3 random materi for additional objects
      final additionalMateri = shuffledMateri.skip(7).take(3).toList();
      
      // Combine all materi for game objects (10 total)
      final allGameMateri = [...questionMateri, ...additionalMateri];
      allGameMateri.shuffle(_random);
      
      // Create game objects with well-distributed positions
      final gameObjects = _generateWellDistributedPositions(allGameMateri);
      
      emit(Level3GameLoaded(
        allMateri: questionMateri,
        gameObjects: gameObjects,
        currentQuestion: null,
        score: 0,
        totalQuestions: 7,
        lives: 4,
        answeredQuestions: [],
        lastAnswer: null,
        level: event.level,
      ));
      
      // Start first round
      add(StartLevel3NewRound());
    } catch (e) {
      emit(Level3GameError(e.toString()));
    }
  }

  void _onStartLevel3NewRound(StartLevel3NewRound event, Emitter<Level3FindObjectState> emit) {
    final currentState = state;
    if (currentState is Level3GameLoaded) {
      if (currentState.answeredQuestions.length >= currentState.totalQuestions) {
        // Update game score before emitting completion state
        _updateGameScore(currentState.score, currentState.level);
        
        emit(Level3GameCompleted(
          score: currentState.score,
          totalQuestions: currentState.totalQuestions,
          lives: currentState.lives,
        ));
        return;
      }

      // Find next unanswered question
      final remainingQuestions = currentState.allMateri
          .where((m) => !currentState.answeredQuestions.contains(m.id))
          .toList();
      
      if (remainingQuestions.isNotEmpty) {
        // Select random question type (0: Hanzi, 1: Pinyin, 2: Audio)
        final questionType = _random.nextInt(3);
        final currentMateri = remainingQuestions.first;
        
        emit(currentState.copyWith(
          currentQuestion: Level3Question(
            materi: currentMateri,
            questionType: questionType,
          ),
        ));
      }
    }
  }

  void _onCheckLevel3Answer(CheckLevel3Answer event, Emitter<Level3FindObjectState> emit) {
    final currentState = state;
    if (currentState is Level3GameLoaded) {
      final isCorrect = event.selectedMateri.id == currentState.currentQuestion!.materi.id;
      
      if (isCorrect) {
        // Add to answered questions
        final updatedAnsweredQuestions = List<String>.from(currentState.answeredQuestions)
          ..add(event.selectedMateri.id);
        
        emit(currentState.copyWith(
          answeredQuestions: updatedAnsweredQuestions,
          score: currentState.score + 1,
          lastAnswer: Level3Answer(
            isCorrect: true,
            selectedMateri: event.selectedMateri,
            correctMateri: currentState.currentQuestion!.materi,
          ),
        ));
        
        // Start next round after a short delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          add(StartLevel3NewRound());
        });
      } else {
        // Reduce life when answer is wrong
        final newLives = currentState.lives - 1;
        
        if (newLives <= 0) {
          // Game over when lives are exhausted
          // Update game score before emitting game over state
          _updateGameScore(currentState.score, currentState.level);
          
          emit(Level3GameOver(
            score: currentState.score,
            totalQuestions: currentState.totalQuestions,
          ));
        } else {
          emit(currentState.copyWith(
            lives: newLives,
            lastAnswer: Level3Answer(
              isCorrect: false,
              selectedMateri: event.selectedMateri,
              correctMateri: currentState.currentQuestion!.materi,
            ),
          ));
        }
      }
    }
  }

  /// Update game score in Firestore if the new score is higher
  Future<void> _updateGameScore(int score, int level) async {
    try {
      await _gameScoreService.updateGameScore(level, score);
      
      // Check badge achievements after updating game score
      await _checkBadgeAchievements.call();
    } catch (e) {
      print('Error updating game score: $e');
    }
  }

  List<Level3GameObject> _generateWellDistributedPositions(List<Materi> materiList) {
    final gameObjects = <Level3GameObject>[];
    
    // Define game area dimensions (adjust based on your UI)
    const double gameAreaWidth = 300.0;
    const double gameAreaHeight = 400.0;
    const double imageSize = 80.0; // Size of each image
    const double minDistance = 60.0; // Reduced minimum distance for more natural random placement
    
    for (int i = 0; i < materiList.length; i++) {
      final materi = materiList[i];
      
      // Generate completely random position
      double x, y;
      bool isTooClose = false;
      int attempts = 0;
      const int maxAttempts = 15; // Increased attempts for better random placement
      
      do {
        // Generate random position across the entire game area
        x = _random.nextDouble() * (gameAreaWidth - imageSize);
        y = _random.nextDouble() * (gameAreaHeight - imageSize);
        
        // Check distance from existing objects
        isTooClose = false;
        for (final existingObject in gameObjects) {
          final distance = _calculateDistance(
            x, y, 
            existingObject.position.dx, existingObject.position.dy
          );
          if (distance < minDistance) {
            isTooClose = true;
            break;
          }
        }
        
        attempts++;
      } while (isTooClose && attempts < maxAttempts);
      
      // If we still have overlapping after max attempts, just place it anyway
      // This allows for some natural clustering while preventing complete overlap
      
      gameObjects.add(Level3GameObject(
        materi: materi,
        position: Offset(x, y),
      ));
    }
    
    return gameObjects;
  }
  
  double _calculateDistance(double x1, double y1, double x2, double y2) {
    final dx = x1 - x2;
    final dy = y1 - y2;
    return sqrt(dx * dx + dy * dy);
  }
}
