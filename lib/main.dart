import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/tasks/presentation/cubit/task_cubit.dart';
import 'features/tasks/presentation/pages/tasks_page.dart';
import 'features/theme/presentation/cubit/theme_cubit.dart';
import 'features/theme/presentation/cubit/theme_state.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive, register adapters, open boxes & wire DI
  await InjectionContainer.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => InjectionContainer.createThemeCubit(),
        ),
        BlocProvider<TaskCubit>(
          create: (_) => InjectionContainer.createTaskCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: AppConstants.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            home: const TasksPage(),
          );
        },
      ),
    );
  }
}
