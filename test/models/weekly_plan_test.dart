import 'package:education_planner/education_planner.dart';
import 'package:test/test.dart';

void main() {
  group('WeeklyPlan', () {
    test('creates a plan with required fields', () {
      final weekStart = DateTime(2026, 1, 13); // A Monday
      final plan = WeeklyPlan(
        id: 'plan-1',
        title: 'Week 1 Plan',
        weekStartDate: weekStart,
      );

      expect(plan.id, equals('plan-1'));
      expect(plan.title, equals('Week 1 Plan'));
      expect(plan.weekStartDate, equals(weekStart));
      expect(plan.activities, isEmpty);
    });

    test('weekEndDate returns correct Sunday', () {
      final weekStart = DateTime(2026, 1, 13); // Monday
      final plan = WeeklyPlan(
        id: 'plan-1',
        title: 'Week 1 Plan',
        weekStartDate: weekStart,
      );

      final expectedEnd = DateTime(2026, 1, 19); // Sunday
      expect(plan.weekEndDate, equals(expectedEnd));
    });

    test('addActivity adds an activity to the plan', () {
      final plan = WeeklyPlan(
        id: 'plan-1',
        title: 'Week 1 Plan',
        weekStartDate: DateTime(2026, 1, 13),
      );

      final activity = Activity(
        id: 'activity-1',
        title: 'Study',
        durationMinutes: 60,
        scheduledTime: DateTime(2026, 1, 13, 10, 0),
      );

      plan.addActivity(activity);

      expect(plan.activities.length, equals(1));
      expect(plan.activities.first, equals(activity));
    });

    test('removeActivity removes an activity from the plan', () {
      final plan = WeeklyPlan(
        id: 'plan-1',
        title: 'Week 1 Plan',
        weekStartDate: DateTime(2026, 1, 13),
      );

      final activity = Activity(
        id: 'activity-1',
        title: 'Study',
        durationMinutes: 60,
        scheduledTime: DateTime(2026, 1, 13, 10, 0),
      );

      plan.addActivity(activity);
      expect(plan.activities.length, equals(1));

      final removed = plan.removeActivity('activity-1');

      expect(removed, isTrue);
      expect(plan.activities, isEmpty);
    });

    test('removeActivity returns false for non-existent activity', () {
      final plan = WeeklyPlan(
        id: 'plan-1',
        title: 'Week 1 Plan',
        weekStartDate: DateTime(2026, 1, 13),
      );

      final removed = plan.removeActivity('non-existent');

      expect(removed, isFalse);
    });

    test('completedActivities returns only completed activities', () {
      final plan = WeeklyPlan(
        id: 'plan-1',
        title: 'Week 1 Plan',
        weekStartDate: DateTime(2026, 1, 13),
      );

      plan.addActivity(Activity(
        id: 'activity-1',
        title: 'Study',
        durationMinutes: 60,
        scheduledTime: DateTime(2026, 1, 13, 10, 0),
        isCompleted: true,
      ));

      plan.addActivity(Activity(
        id: 'activity-2',
        title: 'Practice',
        durationMinutes: 30,
        scheduledTime: DateTime(2026, 1, 13, 11, 0),
        isCompleted: false,
      ));

      final completed = plan.completedActivities;

      expect(completed.length, equals(1));
      expect(completed.first.id, equals('activity-1'));
    });

    test('pendingActivities returns only pending activities', () {
      final plan = WeeklyPlan(
        id: 'plan-1',
        title: 'Week 1 Plan',
        weekStartDate: DateTime(2026, 1, 13),
      );

      plan.addActivity(Activity(
        id: 'activity-1',
        title: 'Study',
        durationMinutes: 60,
        scheduledTime: DateTime(2026, 1, 13, 10, 0),
        isCompleted: true,
      ));

      plan.addActivity(Activity(
        id: 'activity-2',
        title: 'Practice',
        durationMinutes: 30,
        scheduledTime: DateTime(2026, 1, 13, 11, 0),
        isCompleted: false,
      ));

      final pending = plan.pendingActivities;

      expect(pending.length, equals(1));
      expect(pending.first.id, equals('activity-2'));
    });

    test('totalPlannedMinutes calculates total duration', () {
      final plan = WeeklyPlan(
        id: 'plan-1',
        title: 'Week 1 Plan',
        weekStartDate: DateTime(2026, 1, 13),
      );

      plan.addActivity(Activity(
        id: 'activity-1',
        title: 'Study',
        durationMinutes: 60,
        scheduledTime: DateTime(2026, 1, 13, 10, 0),
      ));

      plan.addActivity(Activity(
        id: 'activity-2',
        title: 'Practice',
        durationMinutes: 30,
        scheduledTime: DateTime(2026, 1, 13, 11, 0),
      ));

      expect(plan.totalPlannedMinutes, equals(90));
    });

    test('completionPercentage calculates correctly', () {
      final plan = WeeklyPlan(
        id: 'plan-1',
        title: 'Week 1 Plan',
        weekStartDate: DateTime(2026, 1, 13),
      );

      plan.addActivity(Activity(
        id: 'activity-1',
        title: 'Study',
        durationMinutes: 60,
        scheduledTime: DateTime(2026, 1, 13, 10, 0),
        isCompleted: true,
      ));

      plan.addActivity(Activity(
        id: 'activity-2',
        title: 'Practice',
        durationMinutes: 30,
        scheduledTime: DateTime(2026, 1, 13, 11, 0),
        isCompleted: false,
      ));

      expect(plan.completionPercentage, equals(50.0));
    });

    test('completionPercentage returns 0 for empty plan', () {
      final plan = WeeklyPlan(
        id: 'plan-1',
        title: 'Week 1 Plan',
        weekStartDate: DateTime(2026, 1, 13),
      );

      expect(plan.completionPercentage, equals(0.0));
    });

    test('toJson converts plan to JSON', () {
      final plan = WeeklyPlan(
        id: 'plan-1',
        title: 'Week 1 Plan',
        weekStartDate: DateTime(2026, 1, 13),
      );

      plan.addActivity(Activity(
        id: 'activity-1',
        title: 'Study',
        durationMinutes: 60,
        scheduledTime: DateTime(2026, 1, 13, 10, 0),
      ));

      final json = plan.toJson();

      expect(json['id'], equals('plan-1'));
      expect(json['title'], equals('Week 1 Plan'));
      expect(json['weekStartDate'], isA<String>());
      expect(json['activities'], isA<List>());
      expect(json['activities'].length, equals(1));
    });

    test('fromJson creates plan from JSON', () {
      final json = {
        'id': 'plan-1',
        'title': 'Week 1 Plan',
        'weekStartDate': '2026-01-13T00:00:00.000',
        'activities': [
          {
            'id': 'activity-1',
            'title': 'Study',
            'durationMinutes': 60,
            'scheduledTime': '2026-01-13T10:00:00.000',
          }
        ],
      };

      final plan = WeeklyPlan.fromJson(json);

      expect(plan.id, equals('plan-1'));
      expect(plan.title, equals('Week 1 Plan'));
      expect(plan.activities.length, equals(1));
      expect(plan.activities.first.title, equals('Study'));
    });

    test('copyWith creates a new instance with updated fields', () {
      final original = WeeklyPlan(
        id: 'plan-1',
        title: 'Original',
        weekStartDate: DateTime(2026, 1, 13),
      );

      final updated = original.copyWith(title: 'Updated');

      expect(updated.id, equals('plan-1'));
      expect(updated.title, equals('Updated'));
      expect(original.title, equals('Original')); // Original unchanged
    });
  });
}
