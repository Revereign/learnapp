import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/materi.dart';
import '../../../domain/usecases/materi/add_materi.dart';
import '../../../domain/usecases/materi/delete_materi.dart';
import '../../../domain/usecases/materi/get_all_materi.dart';
import '../../../domain/usecases/materi/update_materi.dart';
import 'materi_event.dart';
import 'materi_state.dart';

class MateriBloc extends Bloc<MateriEvent, MateriState> {
  final GetAllMateri getAllMateri;
  final AddMateri addMateri;
  final UpdateMateri updateMateri;
  final DeleteMateri deleteMateri;

  MateriBloc({
    required this.getAllMateri,
    required this.addMateri,
    required this.updateMateri,
    required this.deleteMateri,
  }) : super(MateriInitial()) {
    on<GetAllMateriEvent>(_onGetAllMateri);
    on<AddMateriEvent>(_onAddMateri);
    on<UpdateMateriEvent>(_onUpdateMateri);
    on<DeleteMateriEvent>(_onDeleteMateri);
  }

  Future<void> _onGetAllMateri(
      GetAllMateriEvent event, Emitter<MateriState> emit) async {
    emit(MateriLoading());
    try {
      final result = await getAllMateri();
      emit(MateriLoaded(result));
    } catch (e) {
      emit(MateriError(e.toString()));
    }
  }

  Future<void> _onAddMateri(
      AddMateriEvent event, Emitter<MateriState> emit) async {
    emit(MateriLoading());
    try {
      await addMateri(event.materi);
      add(GetAllMateriEvent()); // Refresh list
    } catch (e) {
      emit(MateriError(e.toString()));
    }
  }


  Future<void> _onUpdateMateri(
      UpdateMateriEvent event, Emitter<MateriState> emit) async {
    emit(MateriLoading());
    try {
      await updateMateri(event.materi);
      add(GetAllMateriEvent()); // Refresh list
    } catch (e) {
      emit(MateriError(e.toString()));
    }
  }


  Future<void> _onDeleteMateri(
      DeleteMateriEvent event, Emitter<MateriState> emit) async {
    emit(MateriLoading());
    try {
      await deleteMateri(event.id);
      add(GetAllMateriEvent()); // Refresh list
    } catch (e) {
      emit(MateriError(e.toString()));
    }
  }
}
