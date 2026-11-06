import '../../../../core/utils/result.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUseCase {
  final TaskRepository repository;

  const UpdateTaskUseCase(this.repository);

  Future<Result<void>> call(TaskEntity task) async {
    return await repository.updateTask(task);
  }
}
