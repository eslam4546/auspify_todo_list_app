import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../cubit/task_state.dart';

enum TaskStatusFilter { all, pending, completed }

class DashboardHeader extends StatelessWidget {
  final TaskState state;
  final TaskStatusFilter selectedStatusFilter;
  final ValueChanged<TaskStatusFilter> onStatusFilterChanged;

  const DashboardHeader({
    super.key,
    required this.state,
    required this.selectedStatusFilter,
    required this.onStatusFilterChanged,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateString = DateFormat('MMM dd').format(DateTime.now());

    final surfaceCardColor = isDark
        ? AppColors.surfaceContainerLowestDark
        : AppColors.surfaceContainerLowestLight;
    final surfaceContainerLow = isDark
        ? AppColors.surfaceContainerLowDark
        : AppColors.surfaceContainerLowLight;
    final surfaceContainer = isDark
        ? AppColors.surfaceContainerDark
        : AppColors.surfaceContainerLight;
    final onSurfaceColor = isDark
        ? AppColors.onSurfaceDark
        : AppColors.onSurfaceLight;
    final onSurfaceVariantColor = isDark
        ? AppColors.onSurfaceVariantDark
        : AppColors.onSurfaceVariantLight;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final secondaryColor = isDark
        ? AppColors.secondaryDark
        : AppColors.secondarySuccess;
    final secondaryContainerColor = isDark
        ? AppColors.secondaryContainerDark
        : AppColors.secondaryContainerLight;
    final onSecondaryContainerColor = isDark
        ? AppColors.onSecondaryContainerDark
        : AppColors.onSecondaryContainerLight;

    return Container(
      decoration: BoxDecoration(
        color: surfaceCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Spark Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}, Developer',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: onSurfaceColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 15,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Today, $dateString • Sprint Cadence',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: onSurfaceVariantColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bolt_rounded, color: primaryColor, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Linear Execution Tracker Box
          Container(
            decoration: BoxDecoration(
              color: surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: secondaryContainerColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${state.completedCount} Completed',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: onSecondaryContainerColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${state.pendingCount} Pending',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: onSurfaceVariantColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${state.completionPercentage}% velocity',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: state.completionVelocity.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFDAE2FD),
                    valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Filter Chips Segment
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All Tasks',
                  count: state.totalCount,
                  isSelected: selectedStatusFilter == TaskStatusFilter.all,
                  onTap: () => onStatusFilterChanged(TaskStatusFilter.all),
                  primaryColor: primaryColor,
                  surfaceContainer: surfaceContainer,
                  onSurfaceVariant: onSurfaceVariantColor,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Pending',
                  count: state.pendingCount,
                  isSelected: selectedStatusFilter == TaskStatusFilter.pending,
                  onTap: () => onStatusFilterChanged(TaskStatusFilter.pending),
                  primaryColor: primaryColor,
                  surfaceContainer: surfaceContainer,
                  onSurfaceVariant: onSurfaceVariantColor,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Completed',
                  count: state.completedCount,
                  isSelected:
                      selectedStatusFilter == TaskStatusFilter.completed,
                  onTap: () =>
                      onStatusFilterChanged(TaskStatusFilter.completed),
                  primaryColor: primaryColor,
                  surfaceContainer: surfaceContainer,
                  onSurfaceVariant: onSurfaceVariantColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color surfaceContainer,
    required Color onSurfaceVariant,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : surfaceContainer,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : onSurfaceVariant.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
