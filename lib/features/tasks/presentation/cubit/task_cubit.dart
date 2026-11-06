import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/toggle_task_status_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final AddTaskUseCase addTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final ToggleTaskStatusUseCase toggleTaskStatusUseCase;
  final Uuid _uuid;

  TaskCubit({
    required this.getTasksUseCase,
    required this.addTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.toggleTaskStatusUseCase,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid(),
       super(const TaskState());

  Future<void> loadTasks() async {
    emit(state.copyWith(status: TaskStatus.loading));
    final result = await getTasksUseCase();
    result.when(
      onSuccess: (tasks) {
        emit(
          state.copyWith(
            status: TaskStatus.success,
            tasks: tasks,
            errorMessage: null,
          ),
        );
      },
      onFailure: (failure) {
        emit(
          state.copyWith(
            status: TaskStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }

  Future<bool> addTask({
    required String title,
    required String description,
    required DateTime dueDate,
    TaskPriority priority = TaskPriority.low,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      emit(
        state.copyWith(
          status: TaskStatus.failure,
          errorMessage: 'Task title cannot be empty.',
        ),
      );
      return false;
    }

    final newTask = TaskEntity(
      id: _uuid.v4(),
      title: trimmedTitle,
      description: description.trim(),
      dueDate: dueDate,
      isCompleted: false,
      priority: priority,
    );

    final result = await addTaskUseCase(newTask);
    return await result.when(
      onSuccess: (_) async {
        await loadTasks();
        return true;
      },
      onFailure: (failure) async {
        emit(
          state.copyWith(
            status: TaskStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return false;
      },
    );
  }

  Future<bool> updateTask(TaskEntity task) async {
    final result = await updateTaskUseCase(task);
    return await result.when(
      onSuccess: (_) async {
        await loadTasks();
        return true;
      },
      onFailure: (failure) async {
        emit(
          state.copyWith(
            status: TaskStatus.failure,
            errorMessage: failure.message,
          ),
        );
        return false;
      },
    );
  }

  Future<void> deleteTask(String id) async {
    final result = await deleteTaskUseCase(id);
    await result.when(
      onSuccess: (_) async {
        await loadTasks();
      },
      onFailure: (failure) async {
        emit(
          state.copyWith(
            status: TaskStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }

  Future<void> toggleTaskStatus(String id) async {
    final result = await toggleTaskStatusUseCase(id);
    await result.when(
      onSuccess: (_) async {
        await loadTasks();
      },
      onFailure: (failure) async {
        emit(
          state.copyWith(
            status: TaskStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }

  void setTab(TaskNavigationTab tab) {
    emit(state.copyWith(selectedTab: tab));
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void filterByPriority(TaskPriority? priority) {
    if (priority == null) {
      emit(state.copyWith(clearPriorityFilter: true));
    } else {
      emit(state.copyWith(priorityFilter: priority));
    }
  }
}
