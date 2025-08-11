import 'package:equatable/equatable.dart';

abstract class VocabularyEvent extends Equatable {
  const VocabularyEvent();

  @override
  List<Object> get props => [];
}

class LoadVocabulary extends VocabularyEvent {
  final int level;

  const LoadVocabulary(this.level);

  @override
  List<Object> get props => [level];
} 