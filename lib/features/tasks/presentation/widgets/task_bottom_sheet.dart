import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../cubit/task_cubit.dart';

class TaskBottomSheet extends StatefulWidget {
  final TaskEntity? taskToEdit;

  const TaskBottomSheet({super.key, this.taskToEdit});

  static Future<void> show(BuildContext context, {TaskEntity? taskToEdit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<TaskCubit>(),
        child: TaskBottomSheet(taskToEdit: taskToEdit),
      ),
    );
  }

  @override
  State<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends State<TaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TaskPriority _selectedPriority;

  bool get isEditMode => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');

    if (task != null) {
      _selectedDate = task.dueDate;
      _selectedTime = TimeOfDay.fromDateTime(task.dueDate);
      _selectedPriority = task.priority;
    } else {
      final now = DateTime.now();
      _selectedDate = now;
      _selectedTime = TimeOfDay.now();
      _selectedPriority = TaskPriority.low;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final dueDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final cubit = context.read<TaskCubit>();

    if (isEditMode) {
      final updatedTask = widget.taskToEdit!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        dueDate: dueDateTime,
        priority: _selectedPriority,
      );
      final success = await cubit.updateTask(updatedTask);
      if (mounted && success) {
        Navigator.pop(context);
      }
    } else {
      final success = await cubit.addTask(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        dueDate: dueDateTime,
        priority: _selectedPriority,
      );
      if (mounted && success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewInsets = MediaQuery.of(context).viewInsets;

    final sheetBg = isDark
        ? AppColors.surfaceContainerLowestDark
        : AppColors.surfaceContainerLowestLight;
    final inputBg = isDark
        ? AppColors.surfaceContainerLowDark
        : AppColors.surfaceContainerLowLight;
    final onSurfaceColor = isDark
        ? AppColors.onSurfaceDark
        : AppColors.onSurfaceLight;
    final onSurfaceVariant = isDark
        ? AppColors.onSurfaceVariantDark
        : AppColors.onSurfaceVariantLight;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Drag Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Sheet Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceContainerHighDark
                                : AppColors.surfaceContainerLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isEditMode
                                ? Icons.edit_note_rounded
                                : Icons.add_task_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditMode ? 'Edit Task' : 'New Task',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: onSurfaceColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              isEditMode
                                  ? 'Clean Architecture · Update'
                                  : 'Clean Architecture · Offline Hive',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: onSurfaceVariant,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: onSurfaceVariant,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Field 1: Task Title
                Text(
                  'Task Title *',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  maxLength: 64,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: onSurfaceColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g., Implement Hive TypeAdapter',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: inputBg,
                    counterText: '',
                    prefixIcon: Icon(
                      Icons.edit_note_rounded,
                      size: 20,
                      color: onSurfaceVariant,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Field 2: Description
                Text(
                  'Description',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: onSurfaceColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add details, steps, or acceptance criteria...',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: inputBg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Field 3: Schedule (Date & Time pickers)
                Text(
                  'SCHEDULE & DEADLINE',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Date Picker Card
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'DUE DATE',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: onSurfaceVariant,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 15,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM dd, yyyy')
                                    .format(_selectedDate),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: onSurfaceColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Time Picker Card
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'DUE TIME',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: onSurfaceVariant,
                                    ),
                                  ),
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 15,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedTime.format(context),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: onSurfaceColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Field 4: Priority Selector Pills
                Text(
                  'PRIORITY LEVEL',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildPriorityButton(
                        priority: TaskPriority.low,
                        label: 'Low',
                        dotColor: AppColors.outlineLight,
                        isSelected: _selectedPriority == TaskPriority.low,
                        inputBg: inputBg,
                        onSurfaceColor: onSurfaceColor,
                        onSurfaceVariant: onSurfaceVariant,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPriorityButton(
                        priority: TaskPriority.medium,
                        label: 'Medium',
                        dotColor: const Color(0xFFF59E0B),
                        isSelected: _selectedPriority == TaskPriority.medium,
                        inputBg: inputBg,
                        onSurfaceColor: onSurfaceColor,
                        onSurfaceVariant: onSurfaceVariant,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPriorityButton(
                        priority: TaskPriority.high,
                        label: 'High',
                        dotColor: AppColors.errorLight,
                        isSelected: _selectedPriority == TaskPriority.high,
                        inputBg: inputBg,
                        onSurfaceColor: onSurfaceColor,
                        onSurfaceVariant: onSurfaceVariant,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Field 5: Action Buttons
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _onSave,
                          icon: Icon(
                            isEditMode
                                ? Icons.check_circle_rounded
                                : Icons.save_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: Text(
                            isEditMode ? 'Update Task' : 'Save Task',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityButton({
    required TaskPriority priority,
    required String label,
    required Color dotColor,
    required bool isSelected,
    required Color inputBg,
    required Color onSurfaceColor,
    required Color onSurfaceVariant,
    required bool isDark,
  }) {
    Color selectedBg;
    Color selectedTextColor;

    if (priority == TaskPriority.high) {
      selectedBg = isDark
          ? AppColors.errorContainerDark
          : AppColors.errorContainerLight;
      selectedTextColor = isDark
          ? AppColors.onErrorContainerDark
          : AppColors.onErrorContainerLight;
    } else if (priority == TaskPriority.medium) {
      selectedBg = isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
      selectedTextColor = isDark
          ? const Color(0xFFFDE68A)
          : const Color(0xFFB45309);
    } else {
      selectedBg = isDark
          ? AppColors.surfaceContainerHighDark
          : AppColors.surfaceContainerLight;
      selectedTextColor = onSurfaceColor;
    }

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : inputBg,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: priority == TaskPriority.high
                      ? AppColors.errorLight
                      : (priority == TaskPriority.medium
                            ? const Color(0xFFF59E0B)
                            : AppColors.primaryLight),
                  width: 1.5,
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? selectedTextColor : onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
