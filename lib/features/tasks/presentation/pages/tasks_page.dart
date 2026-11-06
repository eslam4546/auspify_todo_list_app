import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../../../theme/presentation/cubit/theme_cubit.dart';
import '../../../theme/presentation/cubit/theme_state.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/task_bottom_sheet.dart';
import '../widgets/task_card.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  TaskStatusFilter _statusFilter = TaskStatusFilter.all;
  bool _isCompletedExpanded = true;

  @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final onSurfaceColor = isDark
        ? AppColors.onSurfaceDark
        : AppColors.onSurfaceLight;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariantDark
        : AppColors.onSurfaceVariantLight;
    final surfaceContainer = isDark
        ? AppColors.surfaceContainerDark
        : AppColors.surfaceContainerLight;
    final secondaryColor = isDark
        ? AppColors.secondaryDark
        : AppColors.secondarySuccess;
    final secondaryContainerColor = isDark
        ? AppColors.secondaryContainerDark
        : AppColors.secondaryContainerLight;
    final onSecondaryContainerColor = isDark
        ? AppColors.onSecondaryContainerDark
        : AppColors.onSecondaryContainerLight;

    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        // Filter tasks by status tab within current view
        final allVisible = state.visibleTasks;
        final pendingTasks = allVisible.where((t) => !t.isCompleted).toList();
        final completedTasks = allVisible.where((t) => t.isCompleted).toList();

        final filteredTasks = switch (_statusFilter) {
          TaskStatusFilter.all => allVisible,
          TaskStatusFilter.pending => pendingTasks,
          TaskStatusFilter.completed => completedTasks,
        };

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Auspify Tasks',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: onSurfaceColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      switch (state.selectedTab) {
                        TaskNavigationTab.today => 'Today Tasks',
                        TaskNavigationTab.agenda => 'Upcoming Agenda',
                        TaskNavigationTab.lists => 'All Task Lists',
                        TaskNavigationTab.insights => 'Productivity Velocity',
                      },
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // Theme Toggle Button
              BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, themeState) {
                  return IconButton(
                    icon: Icon(
                      themeState.isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      size: 20,
                    ),
                    color: onSurfaceVariant,
                    tooltip: 'Toggle Theme',
                    onPressed: () {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: state.status == TaskStatus.loading && state.tasks.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    await context.read<TaskCubit>().loadTasks();
                  },
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: [
                      // Stitch Dashboard Velocity Header
                      DashboardHeader(
                        state: state,
                        selectedStatusFilter: _statusFilter,
                        onStatusFilterChanged: (filter) {
                          setState(() {
                            _statusFilter = filter;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // If Insights Tab is selected, show insights overview
                      if (state.selectedTab == TaskNavigationTab.insights)
                        _buildInsightsView(
                          state,
                          isDark,
                          primaryColor,
                          onSurfaceColor,
                          onSurfaceVariant,
                        )
                      else if (filteredTasks.isEmpty)
                        _buildEmptyState(
                          isDark,
                          onSurfaceColor,
                          onSurfaceVariant,
                          primaryColor,
                        )
                      else ...[
                        // Pending Tasks Section
                        if (_statusFilter != TaskStatusFilter.completed &&
                            pendingTasks.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Pending Tasks',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: onSurfaceColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: surfaceContainer,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${pendingTasks.length}',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: onSurfaceColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Tap check to resolve',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...pendingTasks.map(
                            (task) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TaskCard(
                                task: task,
                                onToggle: () => context
                                    .read<TaskCubit>()
                                    .toggleTaskStatus(task.id),
                                onEdit: () => TaskBottomSheet.show(
                                  context,
                                  taskToEdit: task,
                                ),
                                onDelete: () => context
                                    .read<TaskCubit>()
                                    .deleteTask(task.id),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Completed Tasks Section (Collapsible Accordion)
                        if (_statusFilter != TaskStatusFilter.pending &&
                            completedTasks.isNotEmpty) ...[
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isCompletedExpanded = !_isCompletedExpanded;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Completed',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: onSurfaceColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: secondaryContainerColor,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_rounded,
                                              size: 13,
                                              color: onSecondaryContainerColor,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              '${completedTasks.length}',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    onSecondaryContainerColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    _isCompletedExpanded
                                        ? Icons.expand_more_rounded
                                        : Icons.chevron_right_rounded,
                                    color: onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_isCompletedExpanded)
                            ...completedTasks.map(
                              (task) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: TaskCard(
                                  task: task,
                                  onToggle: () => context
                                      .read<TaskCubit>()
                                      .toggleTaskStatus(task.id),
                                  onEdit: () => TaskBottomSheet.show(
                                    context,
                                    taskToEdit: task,
                                  ),
                                  onDelete: () => context
                                      .read<TaskCubit>()
                                      .deleteTask(task.id),
                                ),
                              ),
                            ),
                        ],
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => TaskBottomSheet.show(context),
            backgroundColor: primaryColor,
            elevation: 4,
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            label: const Text(
              'New Task',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: state.selectedTab.index,
            onDestinationSelected: (index) {
              context.read<TaskCubit>().setTab(TaskNavigationTab.values[index]);
            },
            backgroundColor: isDark
                ? AppColors.surfaceContainerLowestDark
                : AppColors.surfaceContainerLowestLight,
            indicatorColor: primaryColor.withValues(alpha: 0.15),
            elevation: 8,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(
                  Icons.calendar_today_rounded,
                  color: primaryColor,
                ),
                label: 'Today',
              ),
              NavigationDestination(
                icon: const Icon(Icons.view_agenda_outlined),
                selectedIcon: Icon(
                  Icons.view_agenda_rounded,
                  color: primaryColor,
                ),
                label: 'Agenda',
              ),
              NavigationDestination(
                icon: const Icon(Icons.checklist_rounded),
                selectedIcon: Icon(
                  Icons.checklist_rounded,
                  color: primaryColor,
                ),
                label: 'Lists',
              ),
              NavigationDestination(
                icon: const Icon(Icons.pie_chart_outline_rounded),
                selectedIcon: Icon(
                  Icons.pie_chart_rounded,
                  color: primaryColor,
                ),
                label: 'Insights',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    bool isDark,
    Color onSurfaceColor,
    Color onSurfaceVariant,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.done_all_rounded, size: 32, color: primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'All Caught Up!',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: onSurfaceColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No tasks found for the current view.\nTap "+ New Task" to schedule your next task.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsView(
    TaskState state,
    bool isDark,
    Color primaryColor,
    Color onSurfaceColor,
    Color onSurfaceVariant,
  ) {
    final highPriorityCount = state.tasks
        .where((t) => t.priority == TaskPriority.high)
        .length;
    final mediumPriorityCount = state.tasks
        .where((t) => t.priority == TaskPriority.medium)
        .length;
    final lowPriorityCount = state.tasks
        .where((t) => t.priority == TaskPriority.low)
        .length;

    final cardBg = isDark
        ? AppColors.surfaceContainerLowestDark
        : AppColors.surfaceContainerLowestLight;
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Velocity & Priority Distribution',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: onSurfaceColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildMetricRow(
            'Total Tasks Logged',
            '${state.totalCount}',
            onSurfaceColor,
            onSurfaceVariant,
          ),
          _buildMetricRow(
            'Tasks Completed',
            '${state.completedCount}',
            onSurfaceColor,
            onSurfaceVariant,
          ),
          _buildMetricRow(
            'Tasks Pending',
            '${state.pendingCount}',
            onSurfaceColor,
            onSurfaceVariant,
          ),
          _buildMetricRow(
            'Completion Rate',
            '${state.completionPercentage}%',
            primaryColor,
            onSurfaceVariant,
          ),
          const Divider(height: 24),
          Text(
            'Priority Breakdown',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: onSurfaceColor,
            ),
          ),
          const SizedBox(height: 10),
          _buildMetricRow(
            'High Priority Tasks',
            '$highPriorityCount',
            AppColors.errorLight,
            onSurfaceVariant,
          ),
          _buildMetricRow(
            'Medium Priority Tasks',
            '$mediumPriorityCount',
            const Color(0xFFF59E0B),
            onSurfaceVariant,
          ),
          _buildMetricRow(
            'Low Priority Tasks',
            '$lowPriorityCount',
            onSurfaceColor,
            onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    Color valueColor,
    Color labelColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: labelColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
