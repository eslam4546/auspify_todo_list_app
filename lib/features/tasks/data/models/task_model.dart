import 'package:hive/hive.dart';

import '../../domain/entities/task_entity.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends TaskEntity {
  @HiveField(5)
  final String priorityString;

  TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.dueDate,
    super.isCompleted = false,
    this.priorityString = 'low',
  }) : super(priority: TaskPriority.fromString(priorityString));

  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get title => super.title;

  @HiveField(2)
  @override
  String get description => super.description;

  @HiveField(3)
  @override
  DateTime get dueDate => super.dueDate;

  @HiveField(4)
  @override
  bool get isCompleted => super.isCompleted;

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      isCompleted: entity.isCompleted,
      priorityString: entity.priority.name,
    );
  }

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      isCompleted: isCompleted,
      priority: TaskPriority.fromString(priorityString),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priorityString,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      isCompleted: map['isCompleted'] as bool? ?? false,
      priorityString: map['priority'] as String? ?? 'low',
    );
  }

  @override
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    TaskPriority? priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priorityString: priority != null ? priority.name : priorityString,
    );
  }
}
