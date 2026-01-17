import 'package:education_planner/education_planner.dart';

void main() {
  print('=== Education Planner Demo ===\n');

  // Create services
  final goalService = EducationGoalService();
  final planService = WeeklyPlanService();

  // Create education goals
  print('Creating education goals...');
  final goal1 = goalService.createGoal(
    id: 'goal-1',
    title: 'Learn Dart Programming',
    description: 'Master Dart language fundamentals and advanced concepts',
    targetDate: DateTime.now().add(const Duration(days: 90)),
  );

  final goal2 = goalService.createGoal(
    id: 'goal-2',
    title: 'Study Data Structures',
    description: 'Complete data structures and algorithms course',
    targetDate: DateTime.now().add(const Duration(days: 60)),
  );

  print('Created ${goalService.totalGoals} goals\n');

  // Create a weekly plan
  print('Creating weekly plan...');
  final weekStart = DateTime.now();
  final plan = planService.createPlan(
    id: 'plan-1',
    title: 'Week of ${weekStart.month}/${weekStart.day}',
    weekStartDate: weekStart,
  );

  // Add activities to the plan
  print('Adding activities to the plan...');
  planService.addActivityToPlan(
    'plan-1',
    Activity(
      id: 'activity-1',
      title: 'Read Dart documentation',
      description: 'Read chapters 1-3 of Dart language tour',
      goalId: goal1.id,
      durationMinutes: 90,
      scheduledTime: weekStart.add(const Duration(hours: 9)),
    ),
  );

  planService.addActivityToPlan(
    'plan-1',
    Activity(
      id: 'activity-2',
      title: 'Practice coding exercises',
      description: 'Complete 5 Dart coding challenges',
      goalId: goal1.id,
      durationMinutes: 120,
      scheduledTime: weekStart.add(const Duration(days: 1, hours: 10)),
    ),
  );

  planService.addActivityToPlan(
    'plan-1',
    Activity(
      id: 'activity-3',
      title: 'Study Binary Trees',
      description: 'Watch video lectures on binary tree traversal',
      goalId: goal2.id,
      durationMinutes: 60,
      scheduledTime: weekStart.add(const Duration(days: 2, hours: 14)),
    ),
  );

  print('Added ${plan.activities.length} activities\n');

  // Display plan details
  print('=== Weekly Plan Details ===');
  print('Plan: ${plan.title}');
  print('Week: ${plan.weekStartDate.toIso8601String().split('T')[0]} to ${plan.weekEndDate.toIso8601String().split('T')[0]}');
  print('Total planned time: ${plan.totalPlannedMinutes} minutes (${(plan.totalPlannedMinutes / 60).toStringAsFixed(1)} hours)');
  print('Completion: ${plan.completionPercentage.toStringAsFixed(1)}%\n');

  // Display activities
  print('=== Activities ===');
  for (final activity in plan.activities) {
    print('- ${activity.title}');
    print('  Goal: ${activity.goalId}');
    print('  Duration: ${activity.durationMinutes} minutes');
    print('  Scheduled: ${activity.scheduledTime.toIso8601String()}');
    print('  Status: ${activity.isCompleted ? "Completed" : "Pending"}');
    print('');
  }

  // Complete some activities
  print('Completing activities...');
  planService.completeActivity('plan-1', 'activity-1');
  planService.completeActivity('plan-1', 'activity-3');
  print('Completed 2 activities\n');

  print('Updated completion: ${plan.completionPercentage.toStringAsFixed(1)}%');
  print('Completed activities: ${plan.completedActivities.length}');
  print('Pending activities: ${plan.pendingActivities.length}\n');

  // Display goal statistics
  print('=== Education Goals Summary ===');
  print('Total goals: ${goalService.totalGoals}');
  print('Active goals: ${goalService.getActiveGoals().length}');
  print('Completed goals: ${goalService.getCompletedGoals().length}');
  print('Overall completion: ${goalService.completionPercentage.toStringAsFixed(1)}%\n');

  // Show activities per goal
  print('=== Activities by Goal ===');
  for (final goal in goalService.getAllGoals()) {
    final activities = planService.getActivitiesForGoal(goal.id);
    print('${goal.title}: ${activities.length} activities');
    final completedCount = activities.where((a) => a.isCompleted).length;
    print('  Progress: $completedCount/${activities.length} completed\n');
  }

  print('=== Demo Complete ===');
}
