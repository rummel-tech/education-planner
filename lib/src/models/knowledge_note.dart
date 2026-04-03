import 'dart:convert';

/// The type/category of a knowledge note
enum NoteType {
  fleeting,
  concept,
  reference,
  question,
  insight,
}

extension NoteTypeExtension on NoteType {
  String get label {
    switch (this) {
      case NoteType.fleeting:
        return 'Fleeting';
      case NoteType.concept:
        return 'Concept';
      case NoteType.reference:
        return 'Reference';
      case NoteType.question:
        return 'Question';
      case NoteType.insight:
        return 'Insight';
    }
  }

  String get value => name;

  static NoteType fromValue(String value) {
    return NoteType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NoteType.fleeting,
    );
  }
}

/// Represents a knowledge note in the personal knowledge system (Zettelkasten-style)
class KnowledgeNote {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final List<String> linkedNoteIds;
  final List<String> linkedGoalIds;
  final String? sourceUrl;
  final NoteType noteType;

  KnowledgeNote({
    required this.id,
    required this.title,
    this.body = '',
    required this.createdAt,
    required this.updatedAt,
    List<String>? tags,
    List<String>? linkedNoteIds,
    List<String>? linkedGoalIds,
    this.sourceUrl,
    this.noteType = NoteType.fleeting,
  })  : tags = tags ?? [],
        linkedNoteIds = linkedNoteIds ?? [],
        linkedGoalIds = linkedGoalIds ?? [];

  bool get isFleeting => noteType == NoteType.fleeting;

  KnowledgeNote copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    List<String>? linkedNoteIds,
    List<String>? linkedGoalIds,
    String? sourceUrl,
    NoteType? noteType,
    bool clearSourceUrl = false,
  }) {
    return KnowledgeNote(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? List.from(this.tags),
      linkedNoteIds: linkedNoteIds ?? List.from(this.linkedNoteIds),
      linkedGoalIds: linkedGoalIds ?? List.from(this.linkedGoalIds),
      sourceUrl: clearSourceUrl ? null : (sourceUrl ?? this.sourceUrl),
      noteType: noteType ?? this.noteType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': jsonEncode(tags),
      'linkedNoteIds': jsonEncode(linkedNoteIds),
      'linkedGoalIds': jsonEncode(linkedGoalIds),
      'sourceUrl': sourceUrl,
      'noteType': noteType.value,
    };
  }

  factory KnowledgeNote.fromJson(Map<String, dynamic> json) {
    List<String> _decodeList(dynamic value) {
      if (value == null) return [];
      if (value is List) return List<String>.from(value);
      if (value is String) {
        final decoded = jsonDecode(value);
        if (decoded is List) return List<String>.from(decoded);
      }
      return [];
    }

    return KnowledgeNote(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags: _decodeList(json['tags']),
      linkedNoteIds: _decodeList(json['linkedNoteIds']),
      linkedGoalIds: _decodeList(json['linkedGoalIds']),
      sourceUrl: json['sourceUrl'] as String?,
      noteType: NoteTypeExtension.fromValue(
        json['noteType'] as String? ?? 'fleeting',
      ),
    );
  }

  @override
  String toString() {
    return 'KnowledgeNote(id: $id, title: $title, type: ${noteType.label})';
  }
}
