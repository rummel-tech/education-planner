/// A flashcard for spaced-repetition review, using the SM-2 algorithm
class ReviewCard {
  final String id;
  final String front;
  final String back;

  /// Optional: the note this card was generated from
  final String? noteId;

  final DateTime createdAt;

  /// The next date this card is due for review
  DateTime nextReviewDate;

  /// Current interval in days between reviews
  int intervalDays;

  /// Ease factor — controls how quickly the interval grows (min 1.3)
  double easeFactor;

  /// Number of times this card has been successfully reviewed in sequence
  int repetitionCount;

  ReviewCard({
    required this.id,
    required this.front,
    required this.back,
    this.noteId,
    required this.createdAt,
    required this.nextReviewDate,
    this.intervalDays = 1,
    this.easeFactor = 2.5,
    this.repetitionCount = 0,
  });

  bool get isDueToday {
    final now = DateTime.now();
    return nextReviewDate.isBefore(
      DateTime(now.year, now.month, now.day + 1),
    );
  }

  ReviewCard copyWith({
    String? id,
    String? front,
    String? back,
    String? noteId,
    DateTime? createdAt,
    DateTime? nextReviewDate,
    int? intervalDays,
    double? easeFactor,
    int? repetitionCount,
    bool clearNoteId = false,
  }) {
    return ReviewCard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      noteId: clearNoteId ? null : (noteId ?? this.noteId),
      createdAt: createdAt ?? this.createdAt,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitionCount: repetitionCount ?? this.repetitionCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'front': front,
      'back': back,
      'noteId': noteId,
      'createdAt': createdAt.toIso8601String(),
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'intervalDays': intervalDays,
      'easeFactor': easeFactor,
      'repetitionCount': repetitionCount,
    };
  }

  factory ReviewCard.fromJson(Map<String, dynamic> json) {
    return ReviewCard(
      id: json['id'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      noteId: json['noteId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      nextReviewDate: DateTime.parse(json['nextReviewDate'] as String),
      intervalDays: json['intervalDays'] as int? ?? 1,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      repetitionCount: json['repetitionCount'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'ReviewCard(id: $id, front: ${front.length > 30 ? '${front.substring(0, 30)}...' : front}, due: $nextReviewDate)';
  }
}
