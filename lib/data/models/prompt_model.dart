import '../../domain/entities/prompt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PromptModel extends Prompt {
  PromptModel({
    required super.id,
    required super.promptOrder,
  });

  factory PromptModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PromptModel(
      id: doc.id,
      promptOrder: data['prompt_order'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt_order': promptOrder,
    };
  }

  Prompt toEntity() {
    return Prompt(
      id: id,
      promptOrder: promptOrder,
    );
  }
}
