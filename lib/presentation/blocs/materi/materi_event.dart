import '../../../domain/entities/materi.dart';

abstract class MateriEvent {}

class GetAllMateriEvent extends MateriEvent {}

class AddMateriEvent extends MateriEvent {
  final Materi materi;
  AddMateriEvent(this.materi);
}

class UpdateMateriEvent extends MateriEvent {
  final Materi materi;
  UpdateMateriEvent(this.materi);
}

class DeleteMateriEvent extends MateriEvent {
  final String id;
  DeleteMateriEvent(this.id);
}
