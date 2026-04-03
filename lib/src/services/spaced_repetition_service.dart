import 'dart:math';

import '../models/knowledge_note.dart';
import '../models/review_card.dart';
import 'database_service.dart';

/// Rating a user can give after seeing the back of a flashcard
enum ReviewRating {
  again,  // complete failure — reset
  hard,   // significant difficulty
  good,   // correct with effort
  easy,   // perfect recall
}

/// Service implementing the SM-2 spaced-repetition algorithm for [ReviewCard]s.
///
/// SM-2 reference: https://www.supermemo.com/en/blog/application-of-a-computer-to-improve-the-results-obtained-in-working-with-the-supermemo-method
class SpacedRepetitionService {
  final Map<String, ReviewCard> _cards = {};
  DatabaseService? _db;

  void attachDatabase(DatabaseService db) {
    _db = db;
  }

  void loadAll(List<ReviewCard> cards) {
    _cards.clear();
    for (final card in cards) {
      _cards[card.id] = card;
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  ReviewCard createCard({
    required String id,
    required String front,
    required String back,
    String? noteId,
  }) {
    final now = DateTime.now();
    final card = ReviewCard(
      id: id,
      front: front,
      back: back,
      noteId: noteId,
      createdAt: now,
      nextReviewDate: now,
    );
    _cards[id] = card;
    _db?.insertCard(card);
    return card;
  }

  /// Creates a review card directly from a [KnowledgeNote].
  /// The front is the note title; the back is the note body.
  ReviewCard createCardFromNote(String id, KnowledgeNote note) {
    return createCard(
      id: id,
      front: note.title,
      back: note.body.isEmpty ? '(no content)' : note.body,
      noteId: note.id,
    );
  }

  ReviewCard? getCard(String id) => _cards[id];

  List<ReviewCard> getAllCards() => _cards.values.toList();

  List<ReviewCard> getDueCards() {
    return _cards.values.where((c) => c.isDueToday).toList()
      ..sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));
  }

  bool deleteCard(String id) {
    final removed = _cards.remove(id) != null;
    if (removed) _db?.deleteCard(id);
    return removed;
  }

  // ── SM-2 Algorithm ─────────────────────────────────────────────────────────

  /// Processes a review rating for [cardId] using SM-2, returning the updated card.
  ReviewCard? recordReview(String cardId, ReviewRating rating) {
    final card = _cards[cardId];
    if (card == null) return null;

    final q = _ratingToQuality(rating);
    final updated = _applySmTwo(card, q);
    _cards[cardId] = updated;
    _db?.updateCard(updated);
    return updated;
  }

  /// Converts a [ReviewRating] to an SM-2 quality score (0–5).
  int _ratingToQuality(ReviewRating rating) {
    switch (rating) {
      case ReviewRating.again:
        return 0;
      case ReviewRating.hard:
        return 2;
      case ReviewRating.good:
        return 3;
      case ReviewRating.easy:
        return 5;
    }
  }

  ReviewCard _applySmTwo(ReviewCard card, int quality) {
    int newInterval;
    double newEaseFactor;
    int newRepetition;

    if (quality < 3) {
      // Failed — restart the learning sequence
      newInterval = 1;
      newRepetition = 0;
      newEaseFactor = card.easeFactor;
    } else {
      newRepetition = card.repetitionCount + 1;
      if (card.repetitionCount == 0) {
        newInterval = 1;
      } else if (card.repetitionCount == 1) {
        newInterval = 6;
      } else {
        newInterval = (card.intervalDays * card.easeFactor).round();
      }
      newEaseFactor = max(
        1.3,
        card.easeFactor +
            (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02)),
      );
    }

    final now = DateTime.now();
    final nextDate = DateTime(
      now.year,
      now.month,
      now.day + newInterval,
    );

    return card.copyWith(
      intervalDays: newInterval,
      easeFactor: newEaseFactor,
      repetitionCount: newRepetition,
      nextReviewDate: nextDate,
    );
  }

  // ── Stats ──────────────────────────────────────────────────────────────────

  int get totalCards => _cards.length;
  int get dueCount => getDueCards().length;

  /// Cards reviewed today (next review date pushed past today)
  int get reviewedTodayCount {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _cards.values
        .where((c) => c.repetitionCount > 0 && c.nextReviewDate.isAfter(tomorrow))
        .length;
  }

  void clear() {
    _cards.clear();
  }
}
