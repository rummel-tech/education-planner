import '../models/knowledge_note.dart';
import 'database_service.dart';

/// Service for managing knowledge notes (Zettelkasten-style)
class KnowledgeNoteService {
  final Map<String, KnowledgeNote> _notes = {};
  DatabaseService? _db;

  void attachDatabase(DatabaseService db) {
    _db = db;
  }

  void loadAll(List<KnowledgeNote> notes) {
    _notes.clear();
    for (final note in notes) {
      _notes[note.id] = note;
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  KnowledgeNote createNote({
    required String id,
    required String title,
    String body = '',
    List<String>? tags,
    List<String>? linkedNoteIds,
    List<String>? linkedGoalIds,
    String? sourceUrl,
    NoteType noteType = NoteType.fleeting,
  }) {
    final now = DateTime.now();
    final note = KnowledgeNote(
      id: id,
      title: title,
      body: body,
      createdAt: now,
      updatedAt: now,
      tags: tags,
      linkedNoteIds: linkedNoteIds,
      linkedGoalIds: linkedGoalIds,
      sourceUrl: sourceUrl,
      noteType: noteType,
    );
    _notes[id] = note;
    _db?.insertNote(note);
    return note;
  }

  KnowledgeNote? getNote(String id) => _notes[id];

  List<KnowledgeNote> getAllNotes() {
    final notes = _notes.values.toList();
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  List<KnowledgeNote> getFleetingNotes() {
    return _notes.values
        .where((n) => n.noteType == NoteType.fleeting)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<KnowledgeNote> getNotesByType(NoteType type) {
    return _notes.values.where((n) => n.noteType == type).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<KnowledgeNote> getNotesByTag(String tag) {
    return _notes.values
        .where((n) => n.tags.contains(tag))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  bool updateNote(String id, KnowledgeNote updatedNote) {
    if (!_notes.containsKey(id)) return false;
    _notes[id] = updatedNote;
    _db?.updateNote(updatedNote);
    return true;
  }

  bool deleteNote(String id) {
    final removed = _notes.remove(id) != null;
    if (removed) _db?.deleteNote(id);
    return removed;
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  List<KnowledgeNote> search(String query) {
    if (query.isEmpty) return getAllNotes();
    final lower = query.toLowerCase();
    return _notes.values
        .where((n) =>
            n.title.toLowerCase().contains(lower) ||
            n.body.toLowerCase().contains(lower) ||
            n.tags.any((t) => t.toLowerCase().contains(lower)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // ── Link traversal ─────────────────────────────────────────────────────────

  List<KnowledgeNote> getLinkedNotes(String noteId) {
    final note = _notes[noteId];
    if (note == null) return [];
    return note.linkedNoteIds
        .map((id) => _notes[id])
        .whereType<KnowledgeNote>()
        .toList();
  }

  List<KnowledgeNote> getNotesLinkedToGoal(String goalId) {
    return _notes.values
        .where((n) => n.linkedGoalIds.contains(goalId))
        .toList();
  }

  // ── Tag helpers ────────────────────────────────────────────────────────────

  List<String> getAllTags() {
    final tags = <String>{};
    for (final note in _notes.values) {
      tags.addAll(note.tags);
    }
    final sorted = tags.toList()..sort();
    return sorted;
  }

  Map<String, int> getTagCounts() {
    final counts = <String, int>{};
    for (final note in _notes.values) {
      for (final tag in note.tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    return counts;
  }

  // ── Stats ──────────────────────────────────────────────────────────────────

  int get totalNotes => _notes.length;

  Map<NoteType, int> get noteCountsByType {
    final counts = <NoteType, int>{};
    for (final note in _notes.values) {
      counts[note.noteType] = (counts[note.noteType] ?? 0) + 1;
    }
    return counts;
  }

  List<KnowledgeNote> getNotesCreatedSince(DateTime since) {
    return _notes.values
        .where((n) => n.createdAt.isAfter(since))
        .toList();
  }

  void clear() {
    _notes.clear();
  }
}
