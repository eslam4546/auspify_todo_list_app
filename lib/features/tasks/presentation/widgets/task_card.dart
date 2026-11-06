import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _buildPriorityBadge(BuildContext context, bool isDark) {
    switch (task.priority) {
      case TaskPriority.high:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.errorContainerDark
                : AppColors.errorContainerLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.priority_high_rounded,
                size: 13,
                color: isDark
                    ? AppColors.onErrorContainerDark
                    : AppColors.onErrorContainerLight,
              ),
              const SizedBox(width: 2),
              Text(
                'High',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.onErrorContainerDark
                      : AppColors.onErrorContainerLight,
                ),
              ),
            ],
          ),
        );
      case TaskPriority.medium:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Medium',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
            ),
          ),
        );
      case TaskPriority.low:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceContainerHighDark
                : AppColors.surfaceContainerLight,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Low',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariantLight,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = task.isCompleted;

    // Stitch Card Styles
    final cardBg = isCompleted
        ? (isDark
              ? AppColors.surfaceContainerLowDark.withValues(alpha: 0.7)
              : AppColors.surfaceContainerLowLight.withValues(alpha: 0.7))
        : (isDark
              ? AppColors.surfaceContainerLowestDark
              : AppColors.surfaceContainerLowestLight);

    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final onSurfaceColor = isDark
        ? AppColors.onSurfaceDark
        : AppColors.onSurfaceLight;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariantDark
        : AppColors.onSurfaceVariantLight;
    final secondaryColor = isDark
        ? AppColors.secondaryDark
        : AppColors.secondarySuccess;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final errorColor = isDark ? AppColors.errorDark : AppColors.errorLight;

    return Dismissible(
      key: Key('task_card_${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: isCompleted
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Checkbox, Title & Priority
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Squircle Checkbox
                InkWell(
                  onTap: onToggle,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(top: 2, right: 12),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? secondaryColor
                          : (isDark
                                ? AppColors.surfaceContainerHighDark
                                : AppColors.surfaceContainerHighLight),
                      borderRadius: BorderRadius.circular(6),
                      border: isCompleted
                          ? null
                          : Border.all(
                              color: isDark
                                  ? AppColors.outlineDark
                                  : AppColors.outlineLight.withValues(
                                      alpha: 0.5,
                                    ),
                              width: 1.5,
                            ),
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),

                // Title & Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isCompleted
                                    ? onSurfaceVariant.withValues(alpha: 0.6)
                                    : onSurfaceColor,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildPriorityBadge(context, isDark),
                        ],
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: isCompleted
                                ? onSurfaceVariant.withValues(alpha: 0.5)
                                : onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bottom Row: Date chip, Time chip & Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Chips
                Row(
                  children: [
                    // Date Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceContainerHighDark
                            : AppColors.surfaceContainerLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_rounded,
                            size: 13,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormatter.formatShortDate(task.dueDate),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Time Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceContainerHighDark
                            : AppColors.surfaceContainerLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormatter.formatTime(task.dueDate),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Edit and Delete Icon Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: onSurfaceVariant,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      splashRadius: 18,
                      onPressed: onEdit,
                      tooltip: 'Edit Task',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      color: onSurfaceVariant,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      splashRadius: 18,
                      onPressed: onDelete,
                      tooltip: 'Delete Task',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
