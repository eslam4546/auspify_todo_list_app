import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list_app/features/tasks/data/models/task_model.dart';
import 'package:to_do_list_app/features/tasks/domain/entities/task_entity.dart';

void main() {
  final testDate = DateTime(2026, 10, 24, 10, 30);
  final testModel = TaskModel(
    id: 'test-123',
    title: 'Test Task',
    description: 'Test Description',
    dueDate: testDate,
    isCompleted: false,
    priorityString: 'high',
  );

  group('TaskModel', () {
    test('should be a subclass of TaskEntity', () {
      expect(testModel, isA<TaskEntity>());
    });

    test('should correctly map to and from TaskEntity', () {
      final entity = testModel.toEntity();
      expect(entity.id, testModel.id);
      expect(entity.title, testModel.title);
      expect(entity.priority, TaskPriority.high);

      final modelFromEntity = TaskModel.fromEntity(entity);
      expect(modelFromEntity.id, entity.id);
      expect(modelFromEntity.priorityString, 'high');
      expect(modelFromEntity.priority, TaskPriority.high);
    });

    test('should correctly serialize to and deserialize from Map', () {
      final map = testModel.toMap();
      expect(map['id'], 'test-123');
      expect(map['title'], 'Test Task');
      expect(map['priority'], 'high');

      final fromMap = TaskModel.fromMap(map);
      expect(fromMap.id, testModel.id);
      expect(fromMap.title, testModel.title);
      expect(fromMap.priority, TaskPriority.high);
    });

    test('should copyWith properly', () {
      final updated = testModel.copyWith(
        isCompleted: true,
        priority: TaskPriority.low,
      );
      expect(updated.isCompleted, true);
      expect(updated.priority, TaskPriority.low);
      expect(updated.priorityString, 'low');
      expect(updated.title, testModel.title);
    });
  });
}
