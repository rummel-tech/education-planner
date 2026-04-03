import 'dart:convert';

/// The type of a learning resource
enum ResourceType {
  book,
  article,
  video,
  course,
  podcast,
  other,
}

extension ResourceTypeExtension on ResourceType {
  String get label {
    switch (this) {
      case ResourceType.book:
        return 'Book';
      case ResourceType.article:
        return 'Article';
      case ResourceType.video:
        return 'Video';
      case ResourceType.course:
        return 'Course';
      case ResourceType.podcast:
        return 'Podcast';
      case ResourceType.other:
        return 'Other';
    }
  }

  String get value => name;

  static ResourceType fromValue(String value) {
    return ResourceType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ResourceType.article,
    );
  }
}

/// The read/consumption status of a resource
enum ReadStatus {
  unread,
  inProgress,
  completed,
}

extension ReadStatusExtension on ReadStatus {
  String get label {
    switch (this) {
      case ReadStatus.unread:
        return 'Unread';
      case ReadStatus.inProgress:
        return 'In Progress';
      case ReadStatus.completed:
        return 'Completed';
    }
  }

  String get value => name;

  static ReadStatus fromValue(String value) {
    return ReadStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReadStatus.unread,
    );
  }
}

/// Represents a learning resource (book, article, video, course, etc.)
class Resource {
  final String id;
  final String title;
  final String url;
  final String? author;
  final ResourceType resourceType;
  final List<String> tags;
  final String notes;
  final List<String> associatedGoalIds;
  ReadStatus readStatus;
  final DateTime createdAt;

  Resource({
    required this.id,
    required this.title,
    this.url = '',
    this.author,
    this.resourceType = ResourceType.article,
    List<String>? tags,
    this.notes = '',
    List<String>? associatedGoalIds,
    this.readStatus = ReadStatus.unread,
    required this.createdAt,
  })  : tags = tags ?? [],
        associatedGoalIds = associatedGoalIds ?? [];

  Resource copyWith({
    String? id,
    String? title,
    String? url,
    String? author,
    ResourceType? resourceType,
    List<String>? tags,
    String? notes,
    List<String>? associatedGoalIds,
    ReadStatus? readStatus,
    DateTime? createdAt,
    bool clearAuthor = false,
  }) {
    return Resource(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      author: clearAuthor ? null : (author ?? this.author),
      resourceType: resourceType ?? this.resourceType,
      tags: tags ?? List.from(this.tags),
      notes: notes ?? this.notes,
      associatedGoalIds: associatedGoalIds ?? List.from(this.associatedGoalIds),
      readStatus: readStatus ?? this.readStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'author': author,
      'resourceType': resourceType.value,
      'tags': jsonEncode(tags),
      'notes': notes,
      'associatedGoalIds': jsonEncode(associatedGoalIds),
      'readStatus': readStatus.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Resource.fromJson(Map<String, dynamic> json) {
    List<String> _decodeList(dynamic value) {
      if (value == null) return [];
      if (value is List) return List<String>.from(value);
      if (value is String) {
        final decoded = jsonDecode(value);
        if (decoded is List) return List<String>.from(decoded);
      }
      return [];
    }

    return Resource(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String? ?? '',
      author: json['author'] as String?,
      resourceType: ResourceTypeExtension.fromValue(
        json['resourceType'] as String? ?? 'article',
      ),
      tags: _decodeList(json['tags']),
      notes: json['notes'] as String? ?? '',
      associatedGoalIds: _decodeList(json['associatedGoalIds']),
      readStatus: ReadStatusExtension.fromValue(
        json['readStatus'] as String? ?? 'unread',
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Resource(id: $id, title: $title, type: ${resourceType.label})';
  }
}
