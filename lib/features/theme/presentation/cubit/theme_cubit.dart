import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final Box settingsBox;

  ThemeCubit({required this.settingsBox})
    : super(
        ThemeState(
          themeMode:
              (settingsBox.get(AppConstants.isDarkModeKey, defaultValue: false)
                  as bool)
              ? ThemeMode.dark
              : ThemeMode.light,
        ),
      );

  Future<void> toggleTheme() async {
    final newIsDarkMode = !state.isDarkMode;
    await settingsBox.put(AppConstants.isDarkModeKey, newIsDarkMode);
    emit(
      ThemeState(themeMode: newIsDarkMode ? ThemeMode.dark : ThemeMode.light),
    );
  }

  Future<void> setTheme({required bool isDarkMode}) async {
    await settingsBox.put(AppConstants.isDarkModeKey, isDarkMode);
    emit(ThemeState(themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light));
  }
}
