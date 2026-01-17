import 'package:education_planner/education_planner.dart';
import 'package:test/test.dart';

void main() {
  group('EducationGoalService', () {
    late EducationGoalService service;

    setUp(() {
      service = EducationGoalService();
    });

    test('createGoal creates and stores a new goal', () {
      final goal = service.createGoal(
        id: 'goal-1',
        title: 'Learn Dart',
        description: 'Master Dart programming',
      );

      expect(goal.id, equals('goal-1'));
      expect(goal.title, equals('Learn Dart'));
      expect(service.totalGoals, equals(1));
    });

    test('getGoal retrieves a goal by id', () {
      service.createGoal(
        id: 'goal-1',
        title: 'Learn Dart',
        description: 'Master Dart programming',
      );

      final retrieved = service.getGoal('goal-1');

      expect(retrieved, isNotNull);
      expect(retrieved!.title, equals('Learn Dart'));
    });

    test('getGoal returns null for non-existent goal', () {
      final retrieved = service.getGoal('non-existent');

      expect(retrieved, isNull);
    });

    test('getAllGoals returns all goals', () {
      service.createGoal(
        id: 'goal-1',
        title: 'Learn Dart',
        description: 'Master Dart programming',
      );
      service.createGoal(
        id: 'goal-2',
        title: 'Learn Flutter',
        description: 'Build mobile apps',
      );

      final allGoals = service.getAllGoals();

      expect(allGoals.length, equals(2));
    });

    test('getActiveGoals returns only incomplete goals', () {
      service.createGoal(
        id: 'goal-1',
        title: 'Learn Dart',
        description: 'Master Dart programming',
      );
      final goal2 = service.createGoal(
        id: 'goal-2',
        title: 'Learn Flutter',
        description: 'Build mobile apps',
      );
      goal2.isCompleted = true;

      final activeGoals = service.getActiveGoals();

      expect(activeGoals.length, equals(1));
      expect(activeGoals.first.id, equals('goal-1'));
    });

    test('getCompletedGoals returns only completed goals', () {
      service.createGoal(
        id: 'goal-1',
        title: 'Learn Dart',
        description: 'Master Dart programming',
      );
      final goal2 = service.createGoal(
        id: 'goal-2',
        title: 'Learn Flutter',
        description: 'Build mobile apps',
      );
      goal2.isCompleted = true;

      final completedGoals = service.getCompletedGoals();

      expect(completedGoals.length, equals(1));
      expect(completedGoals.first.id, equals('goal-2'));
    });

    test('updateGoal updates an existing goal', () {
      service.createGoal(
        id: 'goal-1',
        title: 'Learn Dart',
        description: 'Master Dart programming',
      );

      final updatedGoal = EducationGoal(
        id: 'goal-1',
        title: 'Advanced Dart',
        description: 'Deep dive into Dart',
        createdAt: DateTime.now(),
      );

      final result = service.updateGoal('goal-1', updatedGoal);

      expect(result, isTrue);
      expect(service.getGoal('goal-1')!.title, equals('Advanced Dart'));
    });

    test('updateGoal returns false for non-existent goal', () {
      final updatedGoal = EducationGoal(
        id: 'goal-1',
        title: 'Advanced Dart',
        description: 'Deep dive into Dart',
        createdAt: DateTime.now(),
      );

      final result = service.updateGoal('goal-1', updatedGoal);

      expect(result, isFalse);
    });

    test('completeGoal marks a goal as completed', () {
      service.createGoal(
        id: 'goal-1',
        title: 'Learn Dart',
        description: 'Master Dart programming',
      );

      final result = service.completeGoal('goal-1');

      expect(result, isTrue);
      expect(service.getGoal('goal-1')!.isCompleted, isTrue);
    });

    test('completeGoal returns false for non-existent goal', () {
      final result = service.completeGoal('non-existent');

      expect(result, isFalse);
    });

    test('deleteGoal removes a goal', () {
      service.createGoal(
        id: 'goal-1',
        title: 'Learn Dart',
        description: 'Master Dart programming',
      );

      expect(service.totalGoals, equals(1));

      final result = service.deleteGoal('goal-1');

      expect(result, isTrue);
      expect(service.totalGoals, equals(0));
      expect(service.getGoal('goal-1'), isNull);
    });

    test('deleteGoal returns false for non-existent goal', () {
      final result = service.deleteGoal('non-existent');

      expect(result, isFalse);
    });

    test('completionPercentage calculates correctly', () {
      service.createGoal(
        id: 'goal-1',
        title: 'Learn Dart',
        description: 'Master Dart programming',
      );
      service.createGoal(
        id: 'goal-2',
        title: 'Learn Flutter',
        description: 'Build mobile apps',
      );

      service.completeGoal('goal-1');

      expect(service.completionPercentage, equals(50.0));
    });

    test('completionPercentage returns 0 for no goals', () {
      expect(service.completionPercentage, equals(0.0));
    });

    test('clear removes all goals', () {
      service.createGoal(
        id: 'goal-1',
        title: 'Learn Dart',
        description: 'Master Dart programming',
      );
      service.createGoal(
        id: 'goal-2',
        title: 'Learn Flutter',
        description: 'Build mobile apps',
      );

      expect(service.totalGoals, equals(2));

      service.clear();

      expect(service.totalGoals, equals(0));
      expect(service.getAllGoals(), isEmpty);
    });
  });
}
