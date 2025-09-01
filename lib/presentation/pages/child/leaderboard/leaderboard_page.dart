import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnapp/presentation/blocs/leaderboard/leaderboard_bloc.dart';
import 'package:learnapp/presentation/blocs/leaderboard/leaderboard_event.dart';
import 'package:learnapp/presentation/blocs/leaderboard/leaderboard_state.dart';
import 'package:learnapp/data/repositories/leaderboard_repository_impl.dart';
import 'package:learnapp/data/datasources/leaderboard_remote_data_source.dart';
import 'package:learnapp/domain/usecases/leaderboard/get_leaderboard.dart';

class LeaderboardPage extends StatelessWidget {
  final int level;

  const LeaderboardPage({
    super.key,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeaderboardBloc(
        getLeaderboard: GetLeaderboard(
          repository: LeaderboardRepositoryImpl(
            remoteDataSource: LeaderboardRemoteDataSourceImpl(),
          ),
        ),
      )..add(LoadLeaderboard(level)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Leaderboard Level $level',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.purple.shade600,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.pink.shade50,
                Colors.purple.shade50,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
            builder: (context, state) {
              if (state is LeaderboardLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.purple,
                        strokeWidth: 4,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Memuat Leaderboard...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is LeaderboardError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Oops! Ada masalah',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error: ${state.message}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            context.read<LeaderboardBloc>().add(LoadLeaderboard(level));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Coba Lagi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is LeaderboardLoaded) {
                return _buildLeaderboardContent(context, state);
              }
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.leaderboard_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(int level) {
    // Semua level menggunakan warna yang sama seperti level 1
    return Colors.red.shade500;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildLeaderboardContent(BuildContext context, LeaderboardLoaded state) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.pink.shade100,
                  Colors.purple.shade100,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _getLevelColor(level).withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.amber.shade300,
                        Colors.orange.shade400,
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.amber.shade300,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Level $level Leaderboard',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _getLevelColor(level),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getLevelColor(level).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Ranking berdasarkan skor tertinggi dan waktu tercepat',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getLevelColor(level),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Leaderboard List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = state.leaderboard[index];
                final rank = index + 1;
                return _buildLeaderboardEntry(context, rank, entry);
              },
              childCount: state.leaderboard.length,
            ),
          ),
        ),
        
        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
      ],
    );
  }

  Widget _buildLeaderboardEntry(BuildContext context, int rank, dynamic entry) {
    final isTopThree = rank <= 3;
    final isEmpty = entry.name == '-';
    
    Color rankColor;
    IconData rankIcon;
    String rankText;
    
    if (rank == 1) {
      rankColor = Colors.amber.shade500;
      rankIcon = Icons.looks_one;
      rankText = '1st';
    } else if (rank == 2) {
      rankColor = Colors.grey.shade400;
      rankIcon = Icons.looks_two;
      rankText = '2nd';
    } else if (rank == 3) {
      rankColor = Colors.orange.shade600;
      rankIcon = Icons.looks_3;
      rankText = '3rd';
    } else {
      rankColor = Colors.blue.shade400;
      rankIcon = Icons.circle;
      rankText = '${rank}th';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.pink.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Rank circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isTopThree ? rankColor : Colors.grey.shade300,
                shape: BoxShape.circle,
                boxShadow: isTopThree ? [
                  BoxShadow(
                    color: rankColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ] : null,
              ),
              child: Center(
                child: isTopThree
                    ? Icon(
                        rankIcon,
                        color: Colors.white,
                        size: 24,
                      )
                    : Text(
                        rankText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // User name
            Expanded(
              child: Text(
                isEmpty ? '-' : entry.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isEmpty ? Colors.grey.shade400 : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Score and time
            if (isEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildScoreDisplay('-', true),
                  const SizedBox(width: 16),
                  _buildScoreDisplay('-', true),
                ],
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildScoreDisplay('${entry.score}', false),
                  const SizedBox(width: 16),
                  _buildScoreDisplay(_formatTime(entry.time), false),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDisplay(String value, bool isEmpty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isEmpty 
            ? Colors.grey.shade100 
            : (value.contains(':') ? Colors.blue.shade100 : Colors.green.shade100),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEmpty 
              ? Colors.grey.shade300 
              : (value.contains(':') ? Colors.blue.shade300 : Colors.green.shade300),
          width: 1,
        ),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isEmpty 
              ? Colors.grey.shade400 
              : (value.contains(':') ? Colors.blue.shade700 : Colors.green.shade700),
        ),
      ),
    );
  }
}
