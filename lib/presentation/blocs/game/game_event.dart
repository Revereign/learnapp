part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class LoadGame extends GameEvent {
  final int level;

  const LoadGame(this.level);

  @override
  List<Object> get props => [level];
}

class StartNewRound extends GameEvent {}

class CheckAnswer extends GameEvent {
  final Materi selectedMateri;

  const CheckAnswer(this.selectedMateri);

  @override
  List<Object> get props => [selectedMateri];
}

class PlayAudio extends GameEvent {
  final Materi materi;

  const PlayAudio(this.materi);

  @override
  List<Object> get props => [materi];
} 