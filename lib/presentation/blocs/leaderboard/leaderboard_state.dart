import 'package:equatable/equatable.dart';
import '../../../domain/entities/leaderboard.dart';

abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardEntity> leaderboard;
  final int level;

  const LeaderboardLoaded({
    required this.leaderboard,
    required this.level,
  });

  @override
  List<Object?> get props => [leaderboard, level];
}

class LeaderboardError extends LeaderboardState {
  final String message;

  const LeaderboardError(this.message);

  @override
  List<Object?> get props => [message];
}
