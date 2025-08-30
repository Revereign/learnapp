import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/materi.dart';
import '../../../../domain/usecases/materi/get_all_materi.dart';
import 'level_event.dart';
import 'level_state.dart';

class LevelBloc extends Bloc<LevelEvent, LevelState> {
  final GetAllMateri getAllMateri;

  LevelBloc({
    required this.getAllMateri,
  }) : super(LevelInitial()) {
    on<LoadLevelsEvent>(_onLoadLevels);
    on<SelectLevelEvent>(_onSelectLevel);
  }

  Future<void> _onLoadLevels(
      LoadLevelsEvent event, Emitter<LevelState> emit) async {
    emit(LevelLoading());
    try {
      final allMateri = await getAllMateri();
      
      // Group materi by level
      final Map<int, List<Materi>> levelGroups = {};
      for (var materi in allMateri) {
        if (!levelGroups.containsKey(materi.level)) {
          levelGroups[materi.level] = [];
        }
        levelGroups[materi.level]!.add(materi);
      }

      // Create 10 levels (1-10) regardless of available materi
      final List<LevelInfo> levels = [];
      for (int i = 1; i <= 10; i++) {
        final materiCount = levelGroups[i]?.length ?? 0;
        levels.add(LevelInfo(
          level: i,
          title: 'Level $i',
          description: _getLevelDescription(i),
          materiCount: materiCount,
          isUnlocked: _isLevelUnlocked(i),
          color: _getLevelColor(i),
        ));
      }

      emit(LevelsLoaded(levels));
    } catch (e) {
      emit(LevelError(e.toString()));
    }
  }

  Future<void> _onSelectLevel(
      SelectLevelEvent event, Emitter<LevelState> emit) async {
    emit(LevelSelected(event.level));
  }

  String _getLevelDescription(int level) {
    switch (level) {
      case 1:
        return 'Warna Dasar';
      case 2:
        return 'Buah-buahan';
      case 3:
        return 'Sayuran';
      case 4:
        return 'Anggota Tubuh';
      case 5:
        return 'Makanan dan Minuman 1';
      case 6:
        return 'Makanan dan Minuman 2';
      case 7:
        return 'Alat Transportasi';
      case 8:
        return 'Hewan';
      case 9:
        return 'Barang Sehari-hari 1';
      case 10:
        return 'Barang Sehari-hari 2';
      default:
        return 'Level ${level}';
    }
  }

  bool _isLevelUnlocked(int level) {
    // Untuk sementara semua level terbuka
    // Nanti bisa diintegrasikan dengan progress user
    return true;
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.red;
      case 6:
        return Colors.pink;
      case 7:
        return Colors.teal;
      case 8:
        return Colors.indigo;
      case 9:
        return Colors.amber;
      case 10:
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }
} 