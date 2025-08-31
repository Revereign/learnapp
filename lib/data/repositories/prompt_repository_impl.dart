import '../../domain/entities/prompt.dart';
import '../../domain/repositories/prompt_repository.dart';
import '../datasources/prompt_remote_data_source.dart';
import '../models/prompt_model.dart';

class PromptRepositoryImpl implements PromptRepository {
  final PromptRemoteDataSource remoteDataSource;

  PromptRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Prompt> getPrompt() async {
    return await remoteDataSource.getPrompt();
  }

  @override
  Future<void> updatePrompt(Prompt prompt) async {
    final model = PromptModel(
      id: prompt.id,
      promptOrder: prompt.promptOrder,
    );
    await remoteDataSource.updatePrompt(model);
  }
}
