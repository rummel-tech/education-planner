import 'package:education_planner/education_planner.dart';
import 'package:test/test.dart';

void main() {
  group('Activity', () {
    test('creates an activity with required fields', () {
      final scheduledTime = DateTime(2026, 1, 15, 10, 0);
      final activity = Activity(
        id: 'activity-1',
        title: 'Study Session',
        durationMinutes: 60,
        scheduledTime: scheduledTime,
      );

      expect(activity.id, equals('activity-1'));
      expect(activity.title, equals('Study Session'));
      expect(activity.durationMinutes, equals(60));
      expect(activity.scheduledTime, equals(scheduledTime));
      expect(activity.isCompleted, isFalse);
      expect(activity.description, isNull);
      expect(activity.goalId, isNull);
    });

    test('creates an activity with optional fields', () {
      final scheduledTime = DateTime(2026, 1, 15, 10, 0);
      final activity = Activity(
        id: 'activity-1',
        title: 'Study Session',
        description: 'Review chapter 3',
        goalId: 'goal-1',
        durationMinutes: 60,
        scheduledTime: scheduledTime,
        isCompleted: true,
      );

      expect(activity.description, equals('Review chapter 3'));
      expect(activity.goalId, equals('goal-1'));
      expect(activity.isCompleted, isTrue);
    });

    test('copyWith creates a new instance with updated fields', () {
      final original = Activity(
        id: 'activity-1',
        title: 'Original',
        durationMinutes: 60,
        scheduledTime: DateTime(2026, 1, 15, 10, 0),
      );

      final updated = original.copyWith(
        title: 'Updated',
        durationMinutes: 90,
        isCompleted: true,
      );

      expect(updated.id, equals('activity-1'));
      expect(updated.title, equals('Updated'));
      expect(updated.durationMinutes, equals(90));
      expect(updated.isCompleted, isTrue);
      expect(original.title, equals('Original')); // Original unchanged
    });

    test('toJson converts activity to JSON', () {
      final activity = Activity(
        id: 'activity-1',
        title: 'Study Session',
        description: 'Review chapter 3',
        goalId: 'goal-1',
        durationMinutes: 60,
        scheduledTime: DateTime(2026, 1, 15, 10, 0),
        isCompleted: true,
      );

      final json = activity.toJson();

      expect(json['id'], equals('activity-1'));
      expect(json['title'], equals('Study Session'));
      expect(json['description'], equals('Review chapter 3'));
      expect(json['goalId'], equals('goal-1'));
      expect(json['durationMinutes'], equals(60));
      expect(json['scheduledTime'], isA<String>());
      expect(json['isCompleted'], isTrue);
    });

    test('fromJson creates activity from JSON', () {
      final json = {
        'id': 'activity-1',
        'title': 'Study Session',
        'description': 'Review chapter 3',
        'goalId': 'goal-1',
        'durationMinutes': 60,
        'scheduledTime': '2026-01-15T10:00:00.000',
        'isCompleted': true,
      };

      final activity = Activity.fromJson(json);

      expect(activity.id, equals('activity-1'));
      expect(activity.title, equals('Study Session'));
      expect(activity.description, equals('Review chapter 3'));
      expect(activity.goalId, equals('goal-1'));
      expect(activity.durationMinutes, equals(60));
      expect(activity.isCompleted, isTrue);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'activity-1',
        'title': 'Study Session',
        'durationMinutes': 60,
        'scheduledTime': '2026-01-15T10:00:00.000',
      };

      final activity = Activity.fromJson(json);

      expect(activity.description, isNull);
      expect(activity.goalId, isNull);
      expect(activity.isCompleted, isFalse);
    });
  });
}
