import '../models/activity.dart';
import '../models/weekly_plan.dart';
import 'database_service.dart';

/// Service for managing weekly plans
class WeeklyPlanService {
  final Map<String, WeeklyPlan> _plans = {};
  DatabaseService? _db;

  void attachDatabase(DatabaseService db) {
    _db = db;
  }

  void loadAll(List<WeeklyPlan> plans) {
    _plans.clear();
    for (final plan in plans) {
      _plans[plan.id] = plan;
    }
  }

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
    _db?.insertPlan(plan);
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
    try {
      return _plans.values.firstWhere(
        (plan) => plan.weekStartDate.isAtSameMomentAs(normalizedDate),
      );
    } catch (_) {
      return null;
    }
  }

  /// Adds an activity to a plan
  bool addActivityToPlan(String planId, Activity activity) {
    final plan = _plans[planId];
    if (plan == null) {
      return false;
    }
    plan.addActivity(activity);
    _db?.insertActivity(planId, activity);
    return true;
  }

  /// Removes an activity from a plan
  bool removeActivityFromPlan(String planId, String activityId) {
    final plan = _plans[planId];
    if (plan == null) {
      return false;
    }
    final removed = plan.removeActivity(activityId);
    if (removed) _db?.deleteActivity(activityId);
    return removed;
  }

  /// Marks an activity as completed
  bool completeActivity(String planId, String activityId) {
    final activity = _findActivity(planId, activityId);
    if (activity == null) return false;
    activity.isCompleted = true;
    _db?.updateActivity(planId, activity);
    return true;
  }

  /// Updates an existing plan
  bool updatePlan(String id, WeeklyPlan updatedPlan) {
    if (!_plans.containsKey(id)) {
      return false;
    }
    _plans[id] = updatedPlan;
    _db?.updatePlan(updatedPlan);
    return true;
  }

  /// Deletes a plan
  bool deletePlan(String id) {
    final removed = _plans.remove(id) != null;
    if (removed) _db?.deletePlan(id);
    return removed;
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

  /// Toggles the completion status of an activity in a plan
  bool toggleActivityCompletion(String planId, String activityId) {
    final activity = _findActivity(planId, activityId);
    if (activity == null) return false;
    activity.isCompleted = !activity.isCompleted;
    _db?.updateActivity(planId, activity);
    return true;
  }

  /// Returns the [Activity] with [activityId] from [planId], or null if not found.
  Activity? _findActivity(String planId, String activityId) {
    final plan = _plans[planId];
    if (plan == null) return null;
    try {
      return plan.activities.firstWhere((a) => a.id == activityId);
    } catch (_) {
      return null;
    }
  }

  /// Gets the total number of plans
  int get totalPlans => _plans.length;

  /// Clears all plans (mainly for testing)
  void clear() {
    _plans.clear();
  }
}
