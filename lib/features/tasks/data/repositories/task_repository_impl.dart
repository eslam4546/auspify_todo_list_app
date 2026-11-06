import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  const TaskRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<List<TaskEntity>>> getTasks() async {
    try {
      final taskModels = await localDataSource.getTasks();
      final taskEntities = taskModels.map((m) => m.toEntity()).toList();
      return Result.success(taskEntities);
    } on DatabaseException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Unexpected error retrieving tasks: $e'),
      );
    }
  }

  @override
  Future<Result<void>> addTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      await localDataSource.addTask(taskModel);
      return Result.success(null);
    } on DatabaseException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Unexpected error adding task: $e'),
      );
    }
  }

  @override
  Future<Result<void>> updateTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      await localDataSource.updateTask(taskModel);
      return Result.success(null);
    } on DatabaseException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Unexpected error updating task: $e'),
      );
    }
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    try {
      await localDataSource.deleteTask(id);
      return Result.success(null);
    } on DatabaseException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Unexpected error deleting task: $e'),
      );
    }
  }

  @override
  Future<Result<void>> toggleTaskStatus(String id) async {
    try {
      await localDataSource.toggleTaskStatus(id);
      return Result.success(null);
    } on DatabaseException catch (e) {
      return Result.failure(DatabaseFailure(e.message));
    } catch (e) {
      return Result.failure(
        DatabaseFailure('Unexpected error toggling task: $e'),
      );
    }
  }
}
