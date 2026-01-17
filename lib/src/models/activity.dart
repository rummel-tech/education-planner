/// Represents an activity in a weekly plan
class Activity {
  final String id;
  final String title;
  final String? description;
  final String? goalId; // Reference to associated education goal
  final int durationMinutes;
  final DateTime scheduledTime;
  bool isCompleted;

  Activity({
    required this.id,
    required this.title,
    this.description,
    this.goalId,
    required this.durationMinutes,
    required this.scheduledTime,
    this.isCompleted = false,
  });

  /// Creates a copy of this activity with the given fields replaced
  Activity copyWith({
    String? id,
    String? title,
    String? description,
    String? goalId,
    int? durationMinutes,
    DateTime? scheduledTime,
    bool? isCompleted,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      goalId: goalId ?? this.goalId,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Converts this activity to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'goalId': goalId,
      'durationMinutes': durationMinutes,
      'scheduledTime': scheduledTime.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  /// Creates an activity from a JSON map
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      goalId: json['goalId'] as String?,
      durationMinutes: json['durationMinutes'] as int,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'Activity(id: $id, title: $title, scheduledTime: $scheduledTime, isCompleted: $isCompleted)';
  }
}
