import '../../../domain/entities/materi.dart';

abstract class MateriState {}

class MateriInitial extends MateriState {}

class MateriLoading extends MateriState {}

class MateriLoaded extends MateriState {
  final List<Materi> materiList;
  MateriLoaded(this.materiList);
}

class MateriSuccess extends MateriState {}

class MateriError extends MateriState {
  final String message;
  MateriError(this.message);
}
