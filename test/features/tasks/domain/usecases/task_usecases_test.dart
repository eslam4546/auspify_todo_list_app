import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list_app/core/utils/result.dart';
import 'package:to_do_list_app/features/tasks/domain/entities/task_entity.dart';
import 'package:to_do_list_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:to_do_list_app/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:to_do_list_app/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:to_do_list_app/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:to_do_list_app/features/tasks/domain/usecases/toggle_task_status_usecase.dart';
import 'package:to_do_list_app/features/tasks/domain/usecases/update_task_usecase.dart';

class MockTaskRepository implements TaskRepository {
  final List<TaskEntity> tasks = [];

  @override
  Future<Result<List<TaskEntity>>> getTasks() async {
    return Result.success(List.unmodifiable(tasks));
  }

  @override
  Future<Result<void>> addTask(TaskEntity task) async {
    tasks.add(task);
    return Result.success(null);
  }

  @override
  Future<Result<void>> updateTask(TaskEntity task) async {
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
    }
    return Result.success(null);
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    tasks.removeWhere((t) => t.id == id);
    return Result.success(null);
  }

  @override
  Future<Result<void>> toggleTaskStatus(String id) async {
    final index = tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final existing = tasks[index];
      tasks[index] = existing.copyWith(isCompleted: !existing.isCompleted);
    }
    return Result.success(null);
  }
}

void main() {
  late MockTaskRepository repository;
  late GetTasksUseCase getTasksUseCase;
  late AddTaskUseCase addTaskUseCase;
  late UpdateTaskUseCase updateTaskUseCase;
  late DeleteTaskUseCase deleteTaskUseCase;
  late ToggleTaskStatusUseCase toggleTaskStatusUseCase;

  setUp(() {
    repository = MockTaskRepository();
    getTasksUseCase = GetTasksUseCase(repository);
    addTaskUseCase = AddTaskUseCase(repository);
    updateTaskUseCase = UpdateTaskUseCase(repository);
    deleteTaskUseCase = DeleteTaskUseCase(repository);
    toggleTaskStatusUseCase = ToggleTaskStatusUseCase(repository);
  });

  final sampleTask = TaskEntity(
    id: 'task-1',
    title: 'Sample Task',
    description: 'Sample Description',
    dueDate: DateTime(2026, 11, 6),
    isCompleted: false,
    priority: TaskPriority.high,
  );

  test('should execute full task CRUD lifecycle across use cases', () async {
    // 1. Add Task
    final addResult = await addTaskUseCase(sampleTask);
    expect(addResult.isSuccess, true);

    // 2. Get Tasks
    var getResult = await getTasksUseCase();
    expect(getResult.isSuccess, true);
    expect(getResult.dataOrNull?.length, 1);
    expect(getResult.dataOrNull?.first.title, 'Sample Task');

    // 3. Toggle Status
    final toggleResult = await toggleTaskStatusUseCase('task-1');
    expect(toggleResult.isSuccess, true);
    getResult = await getTasksUseCase();
    expect(getResult.dataOrNull?.first.isCompleted, true);

    // 4. Update Task
    final updatedTask = sampleTask.copyWith(
      title: 'Updated Title',
      isCompleted: true,
    );
    final updateResult = await updateTaskUseCase(updatedTask);
    expect(updateResult.isSuccess, true);
    getResult = await getTasksUseCase();
    expect(getResult.dataOrNull?.first.title, 'Updated Title');

    // 5. Delete Task
    final deleteResult = await deleteTaskUseCase('task-1');
    expect(deleteResult.isSuccess, true);
    getResult = await getTasksUseCase();
    expect(getResult.dataOrNull?.isEmpty, true);
  });
}
