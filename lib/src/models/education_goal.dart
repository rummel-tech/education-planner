import 'dart:convert';

/// Represents an education goal with a title, description, and completion status
class EducationGoal {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? targetDate;
  bool isCompleted;
  List<String> tags;
  List<String> linkedNoteIds;

  EducationGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.targetDate,
    this.isCompleted = false,
    List<String>? tags,
    List<String>? linkedNoteIds,
  })  : tags = tags ?? [],
        linkedNoteIds = linkedNoteIds ?? [];

  /// Creates a copy of this goal with the given fields replaced
  EducationGoal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? targetDate,
    bool? isCompleted,
    List<String>? tags,
    List<String>? linkedNoteIds,
  }) {
    return EducationGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      tags: tags ?? List.from(this.tags),
      linkedNoteIds: linkedNoteIds ?? List.from(this.linkedNoteIds),
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
      'tags': jsonEncode(tags),
      'linkedNoteIds': jsonEncode(linkedNoteIds),
    };
  }

  /// Creates a goal from a JSON map
  factory EducationGoal.fromJson(Map<String, dynamic> json) {
    List<String> _decodeList(dynamic value) {
      if (value == null) return [];
      if (value is List) return List<String>.from(value);
      if (value is String) {
        final decoded = jsonDecode(value);
        if (decoded is List) return List<String>.from(decoded);
      }
      return [];
    }

    return EducationGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      tags: _decodeList(json['tags']),
      linkedNoteIds: _decodeList(json['linkedNoteIds']),
    );
  }

  @override
  String toString() {
    return 'EducationGoal(id: $id, title: $title, isCompleted: $isCompleted)';
  }
}
