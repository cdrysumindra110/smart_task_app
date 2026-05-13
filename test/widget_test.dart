import 'package:flutter_test/flutter_test.dart';
import 'package:smart_task_app/models/task_model.dart';

void main() {
  group('TaskModel', () {
    test('copyWith updates selected fields only', () {
      final base = TaskModel(
        id: '1',
        title: 'Original',
        description: 'Desc',
        date: DateTime(2026, 1, 1),
        status: TaskStatus.pending,
        userId: 'u1',
      );

      final updated = base.copyWith(
        title: 'Updated',
        status: TaskStatus.completed,
      );

      expect(updated.id, '1');
      expect(updated.title, 'Updated');
      expect(updated.description, 'Desc');
      expect(updated.status, TaskStatus.completed);
      expect(updated.userId, 'u1');
      expect(updated.isCompleted, isTrue);
    });

    test('fromMap falls back safely for missing fields', () {
      final task = TaskModel.fromMap('x', <String, dynamic>{});

      expect(task.id, 'x');
      expect(task.title, '');
      expect(task.description, '');
      expect(task.status, TaskStatus.pending);
      expect(task.userId, '');
    });
  });
}
