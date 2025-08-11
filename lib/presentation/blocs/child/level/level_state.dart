import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LevelState extends Equatable {
  const LevelState();

  @override
  List<Object?> get props => [];
}

class LevelInitial extends LevelState {}

class LevelLoading extends LevelState {}

class LevelsLoaded extends LevelState {
  final List<LevelInfo> levels;

  const LevelsLoaded(this.levels);

  @override
  List<Object?> get props => [levels];
}

class LevelSelected extends LevelState {
  final int level;

  const LevelSelected(this.level);

  @override
  List<Object?> get props => [level];
}

class LevelError extends LevelState {
  final String message;

  const LevelError(this.message);

  @override
  List<Object?> get props => [message];
}

class LevelInfo {
  final int level;
  final String title;
  final String description;
  final int materiCount;
  final bool isUnlocked;
  final Color color;

  LevelInfo({
    required this.level,
    required this.title,
    required this.description,
    required this.materiCount,
    required this.isUnlocked,
    required this.color,
  });
} 