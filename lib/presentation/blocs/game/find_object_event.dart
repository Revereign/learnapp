part of 'find_object_bloc.dart';

abstract class Level3FindObjectEvent extends Equatable {
  const Level3FindObjectEvent();

  @override
  List<Object> get props => [];
}

class LoadLevel3Game extends Level3FindObjectEvent {
  final int level;

  const LoadLevel3Game(this.level);

  @override
  List<Object> get props => [level];
}

class StartLevel3NewRound extends Level3FindObjectEvent {}

class CheckLevel3Answer extends Level3FindObjectEvent {
  final Materi selectedMateri;

  const CheckLevel3Answer(this.selectedMateri);

  @override
  List<Object> get props => [selectedMateri];
}
