import '../../../../core/utils/result.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class AddTaskUseCase {
  final TaskRepository repository;

  const AddTaskUseCase(this.repository);

  Future<Result<void>> call(TaskEntity task) async {
    return await repository.addTask(task);
  }
}
