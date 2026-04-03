import '../models/education_goal.dart';
import 'database_service.dart';

/// Service for managing education goals
class EducationGoalService {
  final Map<String, EducationGoal> _goals = {};
  DatabaseService? _db;

  void attachDatabase(DatabaseService db) {
    _db = db;
  }

  void loadAll(List<EducationGoal> goals) {
    _goals.clear();
    for (final goal in goals) {
      _goals[goal.id] = goal;
    }
  }

  /// Creates a new education goal
  EducationGoal createGoal({
    required String id,
    required String title,
    required String description,
    DateTime? targetDate,
    List<String>? tags,
  }) {
    final goal = EducationGoal(
      id: id,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      targetDate: targetDate,
      tags: tags,
    );
    _goals[id] = goal;
    _db?.insertGoal(goal);
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
    _db?.updateGoal(updatedGoal);
    return true;
  }

  /// Marks a goal as completed
  bool completeGoal(String id) {
    final goal = _goals[id];
    if (goal == null) {
      return false;
    }
    goal.isCompleted = true;
    _db?.updateGoal(goal);
    return true;
  }

  /// Deletes a goal
  bool deleteGoal(String id) {
    final removed = _goals.remove(id) != null;
    if (removed) _db?.deleteGoal(id);
    return removed;
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
