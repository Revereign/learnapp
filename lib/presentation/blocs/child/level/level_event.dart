import 'package:equatable/equatable.dart';

abstract class LevelEvent extends Equatable {
  const LevelEvent();

  @override
  List<Object?> get props => [];
}

class LoadLevelsEvent extends LevelEvent {
  const LoadLevelsEvent();
}

class SelectLevelEvent extends LevelEvent {
  final int level;

  const SelectLevelEvent(this.level);

  @override
  List<Object?> get props => [level];
} 