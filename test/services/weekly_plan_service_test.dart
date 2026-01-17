import 'package:education_planner/education_planner.dart';
import 'package:test/test.dart';

void main() {
  group('WeeklyPlanService', () {
    late WeeklyPlanService service;

    setUp(() {
      service = WeeklyPlanService();
    });

    test('createPlan creates and stores a new plan', () {
      final plan = service.createPlan(
        id: 'plan-1',
        title: 'Week 1',
        weekStartDate: DateTime(2026, 1, 13),
      );

      expect(plan.id, equals('plan-1'));
      expect(plan.title, equals('Week 1'));
      expect(service.totalPlans, equals(1));
    });

    test('createPlan normalizes date to Monday', () {
      // Pass a Thursday (Jan 15, 2026)
      final plan = service.createPlan(
        id: 'plan-1',
        title: 'Week 1',
        weekStartDate: DateTime(2026, 1, 15),
      );

      // Should be normalized to Monday (Jan 12, 2026)
      expect(plan.weekStartDate.day, equals(12));
      expect(plan.weekStartDate.weekday, equals(DateTime.monday));
    });

    test('getPlan retrieves a plan by id', () {
      service.createPlan(
        id: 'plan-1',
        title: 'Week 1',
        weekStartDate: DateTime(2026, 1, 13),
      );

      final retrieved = service.getPlan('plan-1');

      expect(retrieved, isNotNull);
      expect(retrieved!.title, equals('Week 1'));
    });

    test('getPlan returns null for non-existent plan', () {
      final retrieved = service.getPlan('non-existent');

      expect(retrieved, isNull);
    });

    test('getAllPlans returns all plans', () {
      service.createPlan(
        id: 'plan-1',
        title: 'Week 1',
        weekStartDate: DateTime(2026, 1, 13),
      );
      service.createPlan(
        id: 'plan-2',
        title: 'Week 2',
        weekStartDate: DateTime(2026, 1, 20),
      );

      final allPlans = service.getAllPlans();

      expect(allPlans.length, equals(2));
    });

    test('addActivityToPlan adds an activity to a plan', () {
      service.createPlan(
        id: 'plan-1',
        title: 'Week 1',
        weekStartDate: DateTime(2026, 1, 13),
      );

      final activity = Activity(
        id: 'activity-1',
        title: 'Study',
        durationMinutes: 60,
        scheduledTime: DateTime(2026, 1, 13, 10, 0),
      );

      final result = service.addActivityToPlan('plan-1', activity);

      expect(result, isTrue);
      expect(service.getPlan('plan-1')!.activities.length, equals(1));
    });

    test('addActivityToPlan returns false for non-existent plan', () {
      final activity = Activity(
        id: 'activity-1',
        title: 'Study',
        durationMinutes: 60,
        scheduledTime: DateTime(2026, 1, 13, 10, 0),
      );

      final result = service.addActivityToPlan('non-existent', activity);

      expect(result, isFalse);
    });

    test('removeActivityFromPlan removes an activity from a plan', () {
      service.createPlan(
        id: 'plan-1',
        title: 'Week 1',
        weekStartDate: DateTime(2026, 1, 13),
      );

      final activity = Activity(
        id: 'activity-1',
        title: 'Study',
        durationMinutes: 60,
        scheduledTime: DateTime(2026, 1, 13, 10, 0),
      );

      service.addActivityToPlan('plan-1', activity);
      expect(service.getPlan('plan-1')!.activities.length, equals(1));

      final result = service.removeActivityFromPlan('plan-1', 'activity-1');

      expect(result, isTrue);
      expect(service.getPlan('plan-1')!.activities, isEmpty);
    });

    test('removeActivityFromPlan returns false for non-existent plan', () {
      final result = service.removeActivityFromPlan('non-existent', 'activity-1');

      expect(result, isFalse);
    });

    test('completeActivity marks an activity as completed', () {
      service.createPlan(
        id: 'plan-1',
        title: 'Week 1',
        weekStartDate: DateTime(2026, 1, 13),
      );

      final activity = Activity(
        id: 'activity-1',
        title: 'Study',
        durationMinutes: 60,
        scheduledTime: DateTime(2026, 1, 13, 10, 0),
      );

      service.addActivityToPlan('plan-1', activity);

      final result = service.completeActivity('plan-1', 'activity-1');

      expect(result, isTrue);
      expect(service.getPlan('plan-1')!.activities.first.isCompleted, isTrue);
    });

    test('completeActivity returns false for non-existent plan', () {
      final result = service.completeActivity('non-existent', 'activity-1');

      expect(result, isFalse);
    });

    test('completeActivity returns false for non-existent activity', () {
      service.createPlan(
        id: 'plan-1',
        title: 'Week 1',
        weekStartDate: DateTime(2026, 1, 13),
      );

      final result = service.completeActivity('plan-1', 'non-existent');

      expect(result, isFalse);
    });

    test('updatePlan updates an existing plan', () {
      service.createPlan(
        id: 'plan-1',
        title: 'Week 1',
        weekStartDate: DateTime(2026, 1, 13),
      );

      final updatedPlan = WeeklyPlan(
        id: 'plan-1',
        title: 'Updated Week 1',
        weekStartDate: DateTime(2026, 1, 13),
      );

      final result = service.updatePlan('plan-1', updatedPlan);

      expect(result, isTrue);
      expect(service.getPlan('plan-1')!.title, equals('Updated Week 1'));
    });

    test('updatePlan returns false for non-existent plan', () {
      final updatedPlan = WeeklyPlan(
        id: 'plan-1',
        title: 'Updated Week 1',
        weekStartDate: DateTime(2026, 1, 13),
      );

      final result = service.updatePlan('plan-1', updatedPlan);

      expect(result, isFalse);
    });

    test('deletePlan removes a plan', () {
      service.createPlan(
        id: 'plan-1',
        title: 'Week 1',
        weekStartDate: DateTime(2026, 1, 13),
      );

      expect(service.totalPlans, equals(1));

      final result = service.deletePlan('plan-1');

      expect(result, isTrue);
      expect(service.totalPlans, equals(0));
      expect(service.getPlan('plan-1'), isNull);
    });

    test('deletePlan returns false for non-existent plan', () {
      final result = service.deletePlan('non-existent');

      expect(result, isFalse);
    });

    test('getActivitiesForGoal returns all activities for a goal', () {
      service.createPlan(
        id: 'plan-1',
        title: 'Week 1',
        weekStartDate: DateTime(2026, 1, 13),
      );

      service.addActivityToPlan(
        'plan-1',
        Activity(
          id: 'activity-1',
          title: 'Study',
          goalId: 'goal-1',
          durationMinutes: 60,
          scheduledTime: DateTime(2026, 1, 13, 10, 0),
        ),
      );

      service.addActivityToPlan(
        'plan-1',
        Activity(
          id: 'activity-2',
          title: 'Practice',
          goalId: 'goal-1',
          durationMinutes: 30,
          scheduledTime: DateTime(2026, 1, 13, 11, 0),
        ),
      );

      service.addActivityToPlan(
        'plan-1',
        Activity(
          id: 'activity-3',
          title: 'Review',
          goalId: 'goal-2',
          durationMinutes: 45,
          scheduledTime: DateTime(2026, 1, 13, 12, 0),
        ),
      );

      final activitiesForGoal1 = service.getActivitiesForGoal('goal-1');

      expect(activitiesForGoal1.length, equals(2));
      expect(activitiesForGoal1.every((a) => a.goalId == 'goal-1'), isTrue);
    });

    test('getActivitiesForGoal returns empty list for non-existent goal', () {
      final activities = service.getActivitiesForGoal('non-existent');

      expect(activities, isEmpty);
    });

    test('clear removes all plans', () {
      service.createPlan(
        id: 'plan-1',
        title: 'Week 1',
        weekStartDate: DateTime(2026, 1, 13),
      );
      service.createPlan(
        id: 'plan-2',
        title: 'Week 2',
        weekStartDate: DateTime(2026, 1, 20),
      );

      expect(service.totalPlans, equals(2));

      service.clear();

      expect(service.totalPlans, equals(0));
      expect(service.getAllPlans(), isEmpty);
    });
  });
}
