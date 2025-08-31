import '../usecase.dart';
import '../../entities/prompt.dart';
import '../../repositories/prompt_repository.dart';

class GetPrompt implements UseCase<Prompt, NoParams> {
  final PromptRepository repository;

  GetPrompt(this.repository);

  @override
  Future<Prompt> call(NoParams params) async {
    return await repository.getPrompt();
  }
}
