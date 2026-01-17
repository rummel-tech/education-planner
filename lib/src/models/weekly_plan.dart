import 'activity.dart';

/// Represents a weekly plan containing multiple activities
class WeeklyPlan {
  final String id;
  final String title;
  final DateTime weekStartDate; // Monday of the week
  final List<Activity> activities;

  WeeklyPlan({
    required this.id,
    required this.title,
    required this.weekStartDate,
    List<Activity>? activities,
  }) : activities = activities ?? [];

  /// Gets the end date of the week (Sunday)
  DateTime get weekEndDate => weekStartDate.add(const Duration(days: 6));

  /// Adds an activity to the plan
  void addActivity(Activity activity) {
    activities.add(activity);
  }

  /// Removes an activity from the plan
  bool removeActivity(String activityId) {
    final initialLength = activities.length;
    activities.removeWhere((activity) => activity.id == activityId);
    return activities.length < initialLength;
  }

  /// Gets all completed activities
  List<Activity> get completedActivities {
    return activities.where((activity) => activity.isCompleted).toList();
  }

  /// Gets all pending activities
  List<Activity> get pendingActivities {
    return activities.where((activity) => !activity.isCompleted).toList();
  }

  /// Gets the total planned duration in minutes
  int get totalPlannedMinutes {
    return activities.fold(0, (sum, activity) => sum + activity.durationMinutes);
  }

  /// Gets the completion percentage
  double get completionPercentage {
    if (activities.isEmpty) return 0.0;
    final completedCount = activities.where((a) => a.isCompleted).length;
    return (completedCount / activities.length) * 100;
  }

  /// Creates a copy of this plan with the given fields replaced
  WeeklyPlan copyWith({
    String? id,
    String? title,
    DateTime? weekStartDate,
    List<Activity>? activities,
  }) {
    return WeeklyPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      activities: activities ?? List.from(this.activities),
    );
  }

  /// Converts this plan to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'weekStartDate': weekStartDate.toIso8601String(),
      'activities': activities.map((a) => a.toJson()).toList(),
    };
  }

  /// Creates a plan from a JSON map
  factory WeeklyPlan.fromJson(Map<String, dynamic> json) {
    return WeeklyPlan(
      id: json['id'] as String,
      title: json['title'] as String,
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      activities: (json['activities'] as List<dynamic>?)
          ?.map((activityJson) => Activity.fromJson(activityJson as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'WeeklyPlan(id: $id, title: $title, activities: ${activities.length}, completion: ${completionPercentage.toStringAsFixed(1)}%)';
  }
}
