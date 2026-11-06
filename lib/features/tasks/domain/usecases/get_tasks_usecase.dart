import '../../../../core/utils/result.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;

  const GetTasksUseCase(this.repository);

  Future<Result<List<TaskEntity>>> call() async {
    return await repository.getTasks();
  }
}
