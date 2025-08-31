import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prompt_model.dart';

abstract class PromptRemoteDataSource {
  Future<PromptModel> getPrompt();
  Future<void> updatePrompt(PromptModel prompt);
}

class PromptRemoteDataSourceImpl implements PromptRemoteDataSource {
  final FirebaseFirestore firestore;

  PromptRemoteDataSourceImpl({required this.firestore});

  @override
  Future<PromptModel> getPrompt() async {
    final doc = await firestore.collection('prompt').doc('H2oet3Fw2gM3rtyL7GZb').get();
    if (!doc.exists) {
      throw Exception('Prompt document not found');
    }
    return PromptModel.fromDocumentSnapshot(doc);
  }

  @override
  Future<void> updatePrompt(PromptModel prompt) async {
    await firestore.collection('prompt').doc('H2oet3Fw2gM3rtyL7GZb').update(prompt.toJson());
  }
}
