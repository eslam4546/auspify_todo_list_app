import 'package:hive/hive.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<void> toggleTaskStatus(String id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box<TaskModel> tasksBox;

  TaskLocalDataSourceImpl({required this.tasksBox});

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final tasks = tasksBox.values.toList();
      // Sort tasks chronologically by dueDate
      tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return tasks;
    } catch (e) {
      throw DatabaseException('Failed to retrieve tasks: $e');
    }
  }

  @override
  Future<void> addTask(TaskModel task) async {
    try {
      await tasksBox.put(task.id, task);
    } catch (e) {
      throw DatabaseException('Failed to add task: $e');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      if (!tasksBox.containsKey(task.id)) {
        throw DatabaseException('Task with id ${task.id} not found.');
      }
      await tasksBox.put(task.id, task);
    } catch (e) {
      throw DatabaseException('Failed to update task: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      if (!tasksBox.containsKey(id)) {
        throw DatabaseException('Task with id $id not found.');
      }
      await tasksBox.delete(id);
    } catch (e) {
      throw DatabaseException('Failed to delete task: $e');
    }
  }

  @override
  Future<void> toggleTaskStatus(String id) async {
    try {
      final existingTask = tasksBox.get(id);
      if (existingTask == null) {
        throw DatabaseException('Task with id $id not found.');
      }
      final updatedTask = existingTask.copyWith(
        isCompleted: !existingTask.isCompleted,
      );
      await tasksBox.put(id, updatedTask);
    } catch (e) {
      throw DatabaseException('Failed to toggle task status: $e');
    }
  }
}
