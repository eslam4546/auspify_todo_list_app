import '../../../../core/utils/result.dart';
import '../repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;

  const DeleteTaskUseCase(this.repository);

  Future<Result<void>> call(String id) async {
    return await repository.deleteTask(id);
  }
}
