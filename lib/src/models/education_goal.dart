/// Represents an education goal with a title, description, and completion status
class EducationGoal {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? targetDate;
  bool isCompleted;

  EducationGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.targetDate,
    this.isCompleted = false,
  });

  /// Creates a copy of this goal with the given fields replaced
  EducationGoal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? targetDate,
    bool? isCompleted,
  }) {
    return EducationGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Converts this goal to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  /// Creates a goal from a JSON map
  factory EducationGoal.fromJson(Map<String, dynamic> json) {
    return EducationGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'EducationGoal(id: $id, title: $title, isCompleted: $isCompleted)';
  }
}
