import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list_app/features/tasks/domain/entities/task_entity.dart';
import 'package:to_do_list_app/features/tasks/presentation/widgets/task_card.dart';

void main() {
  testWidgets('TaskCard widget smoke test', (WidgetTester tester) async {
    final task = TaskEntity(
      id: 'task-test-1',
      title: 'Smoke Test Title',
      description: 'Smoke Test Description',
      dueDate: DateTime(2026, 11, 6, 10, 30),
      isCompleted: false,
      priority: TaskPriority.high,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: task,
            onToggle: () {},
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Smoke Test Title'), findsOneWidget);
    expect(find.text('Smoke Test Description'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
  });
}
