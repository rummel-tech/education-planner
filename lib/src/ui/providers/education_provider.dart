import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../models/activity.dart';
import '../../models/education_goal.dart';
import '../../models/weekly_plan.dart';
import '../../services/education_goal_service.dart';
import '../../services/weekly_plan_service.dart';

enum GoalFilter { all, active, completed }

class EducationProvider extends ChangeNotifier {
  final EducationGoalService _goalService = EducationGoalService();
  final WeeklyPlanService _planService = WeeklyPlanService();
  final Uuid _uuid = const Uuid();

  GoalFilter _currentFilter = GoalFilter.active;
  DateTime _selectedWeek = DateTime.now();

  GoalFilter get currentFilter => _currentFilter;
  DateTime get selectedWeek => _selectedWeek;

  // Goal operations
  List<EducationGoal> get goals {
    switch (_currentFilter) {
      case GoalFilter.all:
        return _goalService.getAllGoals();
      case GoalFilter.active:
        return _goalService.getActiveGoals();
      case GoalFilter.completed:
        return _goalService.getCompletedGoals();
    }
  }

  List<EducationGoal> get allGoals => _goalService.getAllGoals();

  EducationGoal? getGoal(String id) => _goalService.getGoal(id);

  int get totalGoals => _goalService.totalGoals;
  int get completedGoalsCount => _goalService.completedGoalsCount;
  double get goalsCompletionPercentage => _goalService.completionPercentage;

  void setFilter(GoalFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  EducationGoal createGoal({
    required String title,
    required String description,
    DateTime? targetDate,
  }) {
    final goal = _goalService.createGoal(
      id: _uuid.v4(),
      title: title,
      description: description,
      targetDate: targetDate,
    );
    notifyListeners();
    return goal;
  }

  bool updateGoal(String id, {
    String? title,
    String? description,
    DateTime? targetDate,
    bool? isCompleted,
  }) {
    final goal = _goalService.getGoal(id);
    if (goal == null) return false;

    final updated = goal.copyWith(
      title: title,
      description: description,
      targetDate: targetDate,
      isCompleted: isCompleted,
    );
    final success = _goalService.updateGoal(id, updated);
    if (success) notifyListeners();
    return success;
  }

  bool completeGoal(String id) {
    final success = _goalService.completeGoal(id);
    if (success) notifyListeners();
    return success;
  }

  bool deleteGoal(String id) {
    final success = _goalService.deleteGoal(id);
    if (success) notifyListeners();
    return success;
  }

  // Weekly plan operations
  List<WeeklyPlan> get allPlans => _planService.getAllPlans();

  WeeklyPlan? get currentWeekPlan => _planService.getPlanForWeek(_selectedWeek);

  WeeklyPlan? getPlan(String id) => _planService.getPlan(id);

  void setSelectedWeek(DateTime date) {
    _selectedWeek = date;
    notifyListeners();
  }

  void navigateToPreviousWeek() {
    _selectedWeek = _selectedWeek.subtract(const Duration(days: 7));
    notifyListeners();
  }

  void navigateToNextWeek() {
    _selectedWeek = _selectedWeek.add(const Duration(days: 7));
    notifyListeners();
  }

  void navigateToCurrentWeek() {
    _selectedWeek = DateTime.now();
    notifyListeners();
  }

  WeeklyPlan createPlan({
    required String title,
    required DateTime weekStartDate,
  }) {
    final plan = _planService.createPlan(
      id: _uuid.v4(),
      title: title,
      weekStartDate: weekStartDate,
    );
    notifyListeners();
    return plan;
  }

  WeeklyPlan getOrCreatePlanForWeek(DateTime date) {
    var plan = _planService.getPlanForWeek(date);
    if (plan == null) {
      final monday = _normalizeToMonday(date);
      plan = createPlan(
        title: 'Week of ${_formatDate(monday)}',
        weekStartDate: monday,
      );
    }
    return plan;
  }

  DateTime _normalizeToMonday(DateTime date) {
    final weekday = date.weekday;
    final daysToSubtract = weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysToSubtract));
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  bool deletePlan(String id) {
    final success = _planService.deletePlan(id);
    if (success) notifyListeners();
    return success;
  }

  // Activity operations
  Activity addActivity({
    required String planId,
    required String title,
    String? description,
    String? goalId,
    required int durationMinutes,
    required DateTime scheduledTime,
  }) {
    final activity = Activity(
      id: _uuid.v4(),
      title: title,
      description: description,
      goalId: goalId,
      durationMinutes: durationMinutes,
      scheduledTime: scheduledTime,
    );
    _planService.addActivityToPlan(planId, activity);
    notifyListeners();
    return activity;
  }

  bool removeActivity(String planId, String activityId) {
    final success = _planService.removeActivityFromPlan(planId, activityId);
    if (success) notifyListeners();
    return success;
  }

  bool completeActivity(String planId, String activityId) {
    final success = _planService.completeActivity(planId, activityId);
    if (success) notifyListeners();
    return success;
  }

  bool toggleActivityCompletion(String planId, String activityId) {
    final plan = _planService.getPlan(planId);
    if (plan == null) return false;

    try {
      final activity = plan.activities.firstWhere((a) => a.id == activityId);
      activity.isCompleted = !activity.isCompleted;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  List<Activity> getActivitiesForGoal(String goalId) {
    return _planService.getActivitiesForGoal(goalId);
  }

  // Progress calculations
  double getGoalProgress(String goalId) {
    final activities = getActivitiesForGoal(goalId);
    if (activities.isEmpty) return 0.0;
    final completed = activities.where((a) => a.isCompleted).length;
    return (completed / activities.length) * 100;
  }

  int getTotalTimeSpentOnGoal(String goalId) {
    final activities = getActivitiesForGoal(goalId);
    return activities
        .where((a) => a.isCompleted)
        .fold(0, (sum, a) => sum + a.durationMinutes);
  }
}
