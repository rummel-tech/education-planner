import '../models/education_goal.dart';

/// Service for managing education goals
class EducationGoalService {
  final Map<String, EducationGoal> _goals = {};

  /// Creates a new education goal
  EducationGoal createGoal({
    required String id,
    required String title,
    required String description,
    DateTime? targetDate,
  }) {
    final goal = EducationGoal(
      id: id,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      targetDate: targetDate,
    );
    _goals[id] = goal;
    return goal;
  }

  /// Retrieves a goal by ID
  EducationGoal? getGoal(String id) {
    return _goals[id];
  }

  /// Retrieves all goals
  List<EducationGoal> getAllGoals() {
    return _goals.values.toList();
  }

  /// Retrieves all active (incomplete) goals
  List<EducationGoal> getActiveGoals() {
    return _goals.values.where((goal) => !goal.isCompleted).toList();
  }

  /// Retrieves all completed goals
  List<EducationGoal> getCompletedGoals() {
    return _goals.values.where((goal) => goal.isCompleted).toList();
  }

  /// Updates an existing goal
  bool updateGoal(String id, EducationGoal updatedGoal) {
    if (!_goals.containsKey(id)) {
      return false;
    }
    _goals[id] = updatedGoal;
    return true;
  }

  /// Marks a goal as completed
  bool completeGoal(String id) {
    final goal = _goals[id];
    if (goal == null) {
      return false;
    }
    goal.isCompleted = true;
    return true;
  }

  /// Deletes a goal
  bool deleteGoal(String id) {
    return _goals.remove(id) != null;
  }

  /// Gets the total number of goals
  int get totalGoals => _goals.length;

  /// Gets the number of completed goals
  int get completedGoalsCount => _goals.values.where((g) => g.isCompleted).length;

  /// Gets the completion percentage
  double get completionPercentage {
    if (_goals.isEmpty) return 0.0;
    return (completedGoalsCount / totalGoals) * 100;
  }

  /// Clears all goals (mainly for testing)
  void clear() {
    _goals.clear();
  }
}
