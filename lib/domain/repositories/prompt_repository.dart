import '../entities/prompt.dart';

abstract class PromptRepository {
  Future<Prompt> getPrompt();
  Future<void> updatePrompt(Prompt prompt);
}
