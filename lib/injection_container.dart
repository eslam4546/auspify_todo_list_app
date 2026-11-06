import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'features/tasks/data/datasources/task_local_data_source.dart';
import 'features/tasks/data/models/task_model.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/repositories/task_repository.dart';
import 'features/tasks/domain/usecases/add_task_usecase.dart';
import 'features/tasks/domain/usecases/delete_task_usecase.dart';
import 'features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'features/tasks/domain/usecases/toggle_task_status_usecase.dart';
import 'features/tasks/domain/usecases/update_task_usecase.dart';
import 'features/tasks/presentation/cubit/task_cubit.dart';
import 'features/theme/presentation/cubit/theme_cubit.dart';

class InjectionContainer {
  static late final Box<TaskModel> tasksBox;
  static late final Box settingsBox;

  static late final TaskLocalDataSource taskLocalDataSource;
  static late final TaskRepository taskRepository;

  static late final GetTasksUseCase getTasksUseCase;
  static late final AddTaskUseCase addTaskUseCase;
  static late final UpdateTaskUseCase updateTaskUseCase;
  static late final DeleteTaskUseCase deleteTaskUseCase;
  static late final ToggleTaskStatusUseCase toggleTaskStatusUseCase;

  static Future<void> init() async {
    // 1. Initialize Hive Flutter
    await Hive.initFlutter();

    // 2. Register TypeAdapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskModelAdapter());
    }

    // 3. Open Boxes
    tasksBox = await Hive.openBox<TaskModel>(AppConstants.tasksBoxName);
    settingsBox = await Hive.openBox(AppConstants.settingsBoxName);

    // 4. Data Sources
    taskLocalDataSource = TaskLocalDataSourceImpl(tasksBox: tasksBox);

    // 5. Repositories
    taskRepository = TaskRepositoryImpl(localDataSource: taskLocalDataSource);

    // 6. Use Cases
    getTasksUseCase = GetTasksUseCase(taskRepository);
    addTaskUseCase = AddTaskUseCase(taskRepository);
    updateTaskUseCase = UpdateTaskUseCase(taskRepository);
    deleteTaskUseCase = DeleteTaskUseCase(taskRepository);
    toggleTaskStatusUseCase = ToggleTaskStatusUseCase(taskRepository);
  }

  static TaskCubit createTaskCubit() {
    return TaskCubit(
      getTasksUseCase: getTasksUseCase,
      addTaskUseCase: addTaskUseCase,
      updateTaskUseCase: updateTaskUseCase,
      deleteTaskUseCase: deleteTaskUseCase,
      toggleTaskStatusUseCase: toggleTaskStatusUseCase,
    );
  }

  static ThemeCubit createThemeCubit() {
    return ThemeCubit(settingsBox: settingsBox);
  }
}
