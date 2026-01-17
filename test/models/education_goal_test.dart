import 'package:education_planner/education_planner.dart';
import 'package:test/test.dart';

void main() {
  group('EducationGoal', () {
    test('creates a goal with required fields', () {
      final goal = EducationGoal(
        id: 'test-1',
        title: 'Test Goal',
        description: 'Test Description',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(goal.id, equals('test-1'));
      expect(goal.title, equals('Test Goal'));
      expect(goal.description, equals('Test Description'));
      expect(goal.isCompleted, isFalse);
      expect(goal.targetDate, isNull);
    });

    test('creates a goal with optional target date', () {
      final targetDate = DateTime(2026, 12, 31);
      final goal = EducationGoal(
        id: 'test-1',
        title: 'Test Goal',
        description: 'Test Description',
        createdAt: DateTime(2026, 1, 1),
        targetDate: targetDate,
      );

      expect(goal.targetDate, equals(targetDate));
    });

    test('copyWith creates a new instance with updated fields', () {
      final original = EducationGoal(
        id: 'test-1',
        title: 'Original',
        description: 'Description',
        createdAt: DateTime(2026, 1, 1),
      );

      final updated = original.copyWith(title: 'Updated', isCompleted: true);

      expect(updated.id, equals('test-1'));
      expect(updated.title, equals('Updated'));
      expect(updated.description, equals('Description'));
      expect(updated.isCompleted, isTrue);
      expect(original.title, equals('Original')); // Original unchanged
    });

    test('toJson converts goal to JSON', () {
      final goal = EducationGoal(
        id: 'test-1',
        title: 'Test Goal',
        description: 'Test Description',
        createdAt: DateTime(2026, 1, 1),
        targetDate: DateTime(2026, 12, 31),
        isCompleted: true,
      );

      final json = goal.toJson();

      expect(json['id'], equals('test-1'));
      expect(json['title'], equals('Test Goal'));
      expect(json['description'], equals('Test Description'));
      expect(json['createdAt'], isA<String>());
      expect(json['targetDate'], isA<String>());
      expect(json['isCompleted'], isTrue);
    });

    test('fromJson creates goal from JSON', () {
      final json = {
        'id': 'test-1',
        'title': 'Test Goal',
        'description': 'Test Description',
        'createdAt': '2026-01-01T00:00:00.000',
        'targetDate': '2026-12-31T00:00:00.000',
        'isCompleted': true,
      };

      final goal = EducationGoal.fromJson(json);

      expect(goal.id, equals('test-1'));
      expect(goal.title, equals('Test Goal'));
      expect(goal.description, equals('Test Description'));
      expect(goal.isCompleted, isTrue);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'test-1',
        'title': 'Test Goal',
        'description': 'Test Description',
        'createdAt': '2026-01-01T00:00:00.000',
      };

      final goal = EducationGoal.fromJson(json);

      expect(goal.targetDate, isNull);
      expect(goal.isCompleted, isFalse);
    });
  });
}
