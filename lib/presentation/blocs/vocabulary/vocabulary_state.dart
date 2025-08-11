import 'package:equatable/equatable.dart';
import '../../../domain/entities/materi.dart';

abstract class VocabularyState extends Equatable {
  const VocabularyState();

  @override
  List<Object> get props => [];
}

class VocabularyInitial extends VocabularyState {}

class VocabularyLoading extends VocabularyState {}

class VocabularyLoaded extends VocabularyState {
  final List<Materi> materiList;

  const VocabularyLoaded(this.materiList);

  @override
  List<Object> get props => [materiList];
}

class VocabularyError extends VocabularyState {
  final String message;

  const VocabularyError(this.message);

  @override
  List<Object> get props => [message];
} 