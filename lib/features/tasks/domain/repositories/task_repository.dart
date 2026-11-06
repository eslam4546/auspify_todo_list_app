import '../../../../core/utils/result.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<Result<List<TaskEntity>>> getTasks();
  Future<Result<void>> addTask(TaskEntity task);
  Future<Result<void>> updateTask(TaskEntity task);
  Future<Result<void>> deleteTask(String id);
  Future<Result<void>> toggleTaskStatus(String id);
}
