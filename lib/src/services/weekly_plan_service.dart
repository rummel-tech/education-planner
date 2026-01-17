import '../models/activity.dart';
import '../models/weekly_plan.dart';

/// Service for managing weekly plans
class WeeklyPlanService {
  final Map<String, WeeklyPlan> _plans = {};

  /// Creates a new weekly plan
  WeeklyPlan createPlan({
    required String id,
    required String title,
    required DateTime weekStartDate,
  }) {
    final plan = WeeklyPlan(
      id: id,
      title: title,
      weekStartDate: _normalizeToMonday(weekStartDate),
    );
    _plans[id] = plan;
    return plan;
  }

  /// Normalizes a date to the Monday of its week
  DateTime _normalizeToMonday(DateTime date) {
    final weekday = date.weekday;
    final daysToSubtract = weekday - 1; // Monday is 1
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysToSubtract));
  }

  /// Retrieves a plan by ID
  WeeklyPlan? getPlan(String id) {
    return _plans[id];
  }

  /// Retrieves all plans
  List<WeeklyPlan> getAllPlans() {
    return _plans.values.toList();
  }

  /// Retrieves the plan for a specific week
  WeeklyPlan? getPlanForWeek(DateTime date) {
    final normalizedDate = _normalizeToMonday(date);
    return _plans.values.firstWhere(
      (plan) => plan.weekStartDate.isAtSameMomentAs(normalizedDate),
      orElse: () => throw StateError('No plan found for week'),
    );
  }

  /// Adds an activity to a plan
  bool addActivityToPlan(String planId, Activity activity) {
    final plan = _plans[planId];
    if (plan == null) {
      return false;
    }
    plan.addActivity(activity);
    return true;
  }

  /// Removes an activity from a plan
  bool removeActivityFromPlan(String planId, String activityId) {
    final plan = _plans[planId];
    if (plan == null) {
      return false;
    }
    return plan.removeActivity(activityId);
  }

  /// Marks an activity as completed
  bool completeActivity(String planId, String activityId) {
    final plan = _plans[planId];
    if (plan == null) {
      return false;
    }
    
    final activity = plan.activities.where((a) => a.id == activityId).firstOrNull;
    if (activity == null) {
      return false;
    }
    
    activity.isCompleted = true;
    return true;
  }

  /// Updates an existing plan
  bool updatePlan(String id, WeeklyPlan updatedPlan) {
    if (!_plans.containsKey(id)) {
      return false;
    }
    _plans[id] = updatedPlan;
    return true;
  }

  /// Deletes a plan
  bool deletePlan(String id) {
    return _plans.remove(id) != null;
  }

  /// Gets all activities across all plans for a specific goal
  List<Activity> getActivitiesForGoal(String goalId) {
    final activities = <Activity>[];
    for (final plan in _plans.values) {
      activities.addAll(
        plan.activities.where((activity) => activity.goalId == goalId),
      );
    }
    return activities;
  }

  /// Gets the total number of plans
  int get totalPlans => _plans.length;

  /// Clears all plans (mainly for testing)
  void clear() {
    _plans.clear();
  }
}
