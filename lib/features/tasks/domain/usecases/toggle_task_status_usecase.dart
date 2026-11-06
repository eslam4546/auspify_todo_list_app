import '../../../../core/utils/result.dart';
import '../repositories/task_repository.dart';

class ToggleTaskStatusUseCase {
  final TaskRepository repository;

  const ToggleTaskStatusUseCase(this.repository);

  Future<Result<void>> call(String id) async {
    return await repository.toggleTaskStatus(id);
  }
}
