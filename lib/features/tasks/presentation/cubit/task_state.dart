import 'package:equatable/equatable.dart';

import '../../domain/entities/task_entity.dart';

enum TaskStatus { initial, loading, success, failure }

enum TaskNavigationTab { today, agenda, lists, insights }

class TaskState extends Equatable {
  final TaskStatus status;
  final List<TaskEntity> tasks;
  final TaskNavigationTab selectedTab;
  final String searchQuery;
  final String? errorMessage;
  final TaskPriority? priorityFilter;

  const TaskState({
    this.status = TaskStatus.initial,
    this.tasks = const [],
    this.selectedTab = TaskNavigationTab.today,
    this.searchQuery = '',
    this.errorMessage,
    this.priorityFilter,
  });

  // Productivity & Dashboard Header Metrics
  int get totalCount => tasks.length;
  int get completedCount => tasks.where((t) => t.isCompleted).length;
  int get pendingCount => tasks.where((t) => !t.isCompleted).length;
  double get completionVelocity =>
      totalCount == 0 ? 0.0 : (completedCount / totalCount);
  int get completionPercentage => (completionVelocity * 100).round();

  // Filtered Tasks according to Tab & Search Query
  List<TaskEntity> get visibleTasks {
    final query = searchQuery.trim().toLowerCase();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return tasks.where((task) {
      // Search matching
      if (query.isNotEmpty) {
        final matchesTitle = task.title.toLowerCase().contains(query);
        final matchesDesc = task.description.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc) return false;
      }

      // Priority filter matching
      if (priorityFilter != null && task.priority != priorityFilter) {
        return false;
      }

      // Tab navigation matching
      switch (selectedTab) {
        case TaskNavigationTab.today:
          // Due today or earlier if pending
          return task.dueDate.isBefore(todayEnd);
        case TaskNavigationTab.agenda:
          // All upcoming or scheduled
          return true;
        case TaskNavigationTab.lists:
          return true;
        case TaskNavigationTab.insights:
          return true;
      }
    }).toList();
  }

  TaskState copyWith({
    TaskStatus? status,
    List<TaskEntity>? tasks,
    TaskNavigationTab? selectedTab,
    String? searchQuery,
    String? errorMessage,
    TaskPriority? priorityFilter,
    bool clearPriorityFilter = false,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      selectedTab: selectedTab ?? this.selectedTab,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      priorityFilter: clearPriorityFilter
          ? null
          : (priorityFilter ?? this.priorityFilter),
    );
  }

  @override
  List<Object?> get props => [
    status,
    tasks,
    selectedTab,
    searchQuery,
    errorMessage,
    priorityFilter,
  ];
}
