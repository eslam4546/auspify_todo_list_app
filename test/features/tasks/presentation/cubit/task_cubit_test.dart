import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list_app/core/utils/result.dart';
import 'package:to_do_list_app/features/tasks/domain/entities/task_entity.dart';
import 'package:to_do_list_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:to_do_list_app/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:to_do_list_app/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:to_do_list_app/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:to_do_list_app/features/tasks/domain/usecases/toggle_task_status_usecase.dart';
import 'package:to_do_list_app/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:to_do_list_app/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:to_do_list_app/features/tasks/presentation/cubit/task_state.dart';

class InMemoryTaskRepository implements TaskRepository {
  final List<TaskEntity> _tasks = [];

  @override
  Future<Result<List<TaskEntity>>> getTasks() async {
    return Result.success(List.unmodifiable(_tasks));
  }

  @override
  Future<Result<void>> addTask(TaskEntity task) async {
    _tasks.add(task);
    return Result.success(null);
  }

  @override
  Future<Result<void>> updateTask(TaskEntity task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _tasks[idx] = task;
    }
    return Result.success(null);
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    return Result.success(null);
  }

  @override
  Future<Result<void>> toggleTaskStatus(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _tasks[idx] = _tasks[idx].copyWith(isCompleted: !_tasks[idx].isCompleted);
    }
    return Result.success(null);
  }
}

void main() {
  late InMemoryTaskRepository repository;
  late TaskCubit cubit;

  setUp(() {
    repository = InMemoryTaskRepository();
    cubit = TaskCubit(
      getTasksUseCase: GetTasksUseCase(repository),
      addTaskUseCase: AddTaskUseCase(repository),
      updateTaskUseCase: UpdateTaskUseCase(repository),
      deleteTaskUseCase: DeleteTaskUseCase(repository),
      toggleTaskStatusUseCase: ToggleTaskStatusUseCase(repository),
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('TaskCubit', () {
    test('initial state should be empty with TaskStatus.initial', () {
      expect(cubit.state.status, TaskStatus.initial);
      expect(cubit.state.tasks, isEmpty);
      expect(cubit.state.totalCount, 0);
      expect(cubit.state.completionVelocity, 0.0);
    });

    test('should add task, compute velocity, and toggle status', () async {
      final success = await cubit.addTask(
        title: 'New Unit Test Task',
        description: 'Testing Cubit',
        dueDate: DateTime(2026, 11, 6, 12, 0),
        priority: TaskPriority.high,
      );

      expect(success, true);
      expect(cubit.state.status, TaskStatus.success);
      expect(cubit.state.totalCount, 1);
      expect(cubit.state.pendingCount, 1);
      expect(cubit.state.completedCount, 0);
      expect(cubit.state.completionPercentage, 0);

      // Toggle status
      final createdTaskId = cubit.state.tasks.first.id;
      await cubit.toggleTaskStatus(createdTaskId);

      expect(cubit.state.completedCount, 1);
      expect(cubit.state.pendingCount, 0);
      expect(cubit.state.completionVelocity, 1.0);
      expect(cubit.state.completionPercentage, 100);

      // Delete task
      await cubit.deleteTask(createdTaskId);
      expect(cubit.state.totalCount, 0);
      expect(cubit.state.completionPercentage, 0);
    });

    test('should reject adding task with empty title', () async {
      final success = await cubit.addTask(
        title: '   ',
        description: 'Invalid',
        dueDate: DateTime.now(),
      );

      expect(success, false);
      expect(cubit.state.status, TaskStatus.failure);
      expect(cubit.state.errorMessage, 'Task title cannot be empty.');
    });

    test('should switch tabs and filter tasks correctly', () {
      cubit.setTab(TaskNavigationTab.agenda);
      expect(cubit.state.selectedTab, TaskNavigationTab.agenda);

      cubit.setTab(TaskNavigationTab.insights);
      expect(cubit.state.selectedTab, TaskNavigationTab.insights);
    });
  });
}
