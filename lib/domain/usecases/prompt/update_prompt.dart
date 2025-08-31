import '../usecase.dart';
import '../../entities/prompt.dart';
import '../../repositories/prompt_repository.dart';

class UpdatePrompt implements UseCase<void, Prompt> {
  final PromptRepository repository;

  UpdatePrompt(this.repository);

  @override
  Future<void> call(Prompt params) async {
    return await repository.updatePrompt(params);
  }
}
