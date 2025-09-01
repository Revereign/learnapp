import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/leaderboard/get_leaderboard.dart';
import '../../../domain/entities/leaderboard.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final GetLeaderboard getLeaderboard;

  LeaderboardBloc({required this.getLeaderboard}) : super(LeaderboardInitial()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
  }

  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());
    
    try {
      final List<LeaderboardEntity> leaderboard = await getLeaderboard(event.level);
      emit(LeaderboardLoaded(
        leaderboard: leaderboard,
        level: event.level,
      ));
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }
}
