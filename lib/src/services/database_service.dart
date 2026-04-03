import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/activity.dart';
import '../models/education_goal.dart';
import '../models/knowledge_note.dart';
import '../models/resource.dart';
import '../models/review_card.dart';
import '../models/weekly_plan.dart';

/// Manages the local SQLite database for all entities.
/// Uses a write-through cache pattern: services keep in-memory Maps for fast
/// reads, and call DatabaseService methods (fire-and-forget) on every write.
class DatabaseService {
  static const _dbName = 'artemis_knowledge.db';
  static const _dbVersion = 1;

  Database? _db;

  bool get isOpen => _db != null;

  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS goals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        created_at TEXT NOT NULL,
        target_date TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        tags TEXT NOT NULL DEFAULT '[]',
        linked_note_ids TEXT NOT NULL DEFAULT '[]'
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS weekly_plans (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        week_start_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS activities (
        id TEXT PRIMARY KEY,
        plan_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        goal_id TEXT,
        duration_minutes INTEGER NOT NULL,
        scheduled_time TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (plan_id) REFERENCES weekly_plans(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS knowledge_notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        tags TEXT NOT NULL DEFAULT '[]',
        linked_note_ids TEXT NOT NULL DEFAULT '[]',
        linked_goal_ids TEXT NOT NULL DEFAULT '[]',
        source_url TEXT,
        note_type TEXT NOT NULL DEFAULT 'fleeting'
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS resources (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        url TEXT NOT NULL DEFAULT '',
        author TEXT,
        resource_type TEXT NOT NULL DEFAULT 'article',
        tags TEXT NOT NULL DEFAULT '[]',
        notes TEXT NOT NULL DEFAULT '',
        associated_goal_ids TEXT NOT NULL DEFAULT '[]',
        read_status TEXT NOT NULL DEFAULT 'unread',
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS review_cards (
        id TEXT PRIMARY KEY,
        front TEXT NOT NULL,
        back TEXT NOT NULL,
        note_id TEXT,
        created_at TEXT NOT NULL,
        next_review_date TEXT NOT NULL,
        interval_days INTEGER NOT NULL DEFAULT 1,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        repetition_count INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // ── Goals ──────────────────────────────────────────────────────────────────

  Future<List<EducationGoal>> getGoals() async {
    if (_db == null) return [];
    final rows = await _db!.query('goals');
    return rows.map((r) => EducationGoal.fromJson(_dbRowToGoalJson(r))).toList();
  }

  Future<void> insertGoal(EducationGoal goal) async {
    if (_db == null) return;
    await _db!.insert(
      'goals',
      _goalToDbRow(goal),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateGoal(EducationGoal goal) async {
    if (_db == null) return;
    await _db!.update(
      'goals',
      _goalToDbRow(goal),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteGoal(String id) async {
    if (_db == null) return;
    await _db!.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Map<String, dynamic> _goalToDbRow(EducationGoal g) => {
        'id': g.id,
        'title': g.title,
        'description': g.description,
        'created_at': g.createdAt.toIso8601String(),
        'target_date': g.targetDate?.toIso8601String(),
        'is_completed': g.isCompleted ? 1 : 0,
        'tags': g.toJson()['tags'],
        'linked_note_ids': g.toJson()['linkedNoteIds'],
      };

  Map<String, dynamic> _dbRowToGoalJson(Map<String, dynamic> row) => {
        'id': row['id'],
        'title': row['title'],
        'description': row['description'],
        'createdAt': row['created_at'],
        'targetDate': row['target_date'],
        'isCompleted': (row['is_completed'] as int?) == 1,
        'tags': row['tags'],
        'linkedNoteIds': row['linked_note_ids'],
      };

  // ── Weekly Plans ───────────────────────────────────────────────────────────

  Future<List<WeeklyPlan>> getWeeklyPlans() async {
    if (_db == null) return [];
    final planRows = await _db!.query('weekly_plans');
    final activityRows = await _db!.query('activities');

    final activitiesByPlan = <String, List<Activity>>{};
    for (final row in activityRows) {
      final planId = row['plan_id'] as String;
      activitiesByPlan.putIfAbsent(planId, () => []);
      activitiesByPlan[planId]!.add(Activity.fromJson(_dbRowToActivityJson(row)));
    }

    return planRows.map((r) {
      final id = r['id'] as String;
      return WeeklyPlan(
        id: id,
        title: r['title'] as String,
        weekStartDate: DateTime.parse(r['week_start_date'] as String),
        activities: activitiesByPlan[id] ?? [],
      );
    }).toList();
  }

  Future<void> insertPlan(WeeklyPlan plan) async {
    if (_db == null) return;
    await _db!.insert(
      'weekly_plans',
      {
        'id': plan.id,
        'title': plan.title,
        'week_start_date': plan.weekStartDate.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePlan(WeeklyPlan plan) async {
    if (_db == null) return;
    await _db!.update(
      'weekly_plans',
      {
        'id': plan.id,
        'title': plan.title,
        'week_start_date': plan.weekStartDate.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  Future<void> deletePlan(String id) async {
    if (_db == null) return;
    await _db!.delete('weekly_plans', where: 'id = ?', whereArgs: [id]);
  }

  // ── Activities ─────────────────────────────────────────────────────────────

  Future<void> insertActivity(String planId, Activity activity) async {
    if (_db == null) return;
    await _db!.insert(
      'activities',
      _activityToDbRow(planId, activity),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateActivity(String planId, Activity activity) async {
    if (_db == null) return;
    await _db!.update(
      'activities',
      _activityToDbRow(planId, activity),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<void> deleteActivity(String activityId) async {
    if (_db == null) return;
    await _db!.delete('activities', where: 'id = ?', whereArgs: [activityId]);
  }

  Map<String, dynamic> _activityToDbRow(String planId, Activity a) => {
        'id': a.id,
        'plan_id': planId,
        'title': a.title,
        'description': a.description,
        'goal_id': a.goalId,
        'duration_minutes': a.durationMinutes,
        'scheduled_time': a.scheduledTime.toIso8601String(),
        'is_completed': a.isCompleted ? 1 : 0,
      };

  Map<String, dynamic> _dbRowToActivityJson(Map<String, dynamic> row) => {
        'id': row['id'],
        'title': row['title'],
        'description': row['description'],
        'goalId': row['goal_id'],
        'durationMinutes': row['duration_minutes'],
        'scheduledTime': row['scheduled_time'],
        'isCompleted': (row['is_completed'] as int?) == 1,
      };

  // ── Knowledge Notes ────────────────────────────────────────────────────────

  Future<List<KnowledgeNote>> getKnowledgeNotes() async {
    if (_db == null) return [];
    final rows = await _db!.query('knowledge_notes', orderBy: 'created_at DESC');
    return rows.map((r) => KnowledgeNote.fromJson(_dbRowToNoteJson(r))).toList();
  }

  Future<void> insertNote(KnowledgeNote note) async {
    if (_db == null) return;
    await _db!.insert(
      'knowledge_notes',
      _noteToDbRow(note),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateNote(KnowledgeNote note) async {
    if (_db == null) return;
    await _db!.update(
      'knowledge_notes',
      _noteToDbRow(note),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(String id) async {
    if (_db == null) return;
    await _db!.delete('knowledge_notes', where: 'id = ?', whereArgs: [id]);
  }

  Map<String, dynamic> _noteToDbRow(KnowledgeNote n) {
    final json = n.toJson();
    return {
      'id': json['id'],
      'title': json['title'],
      'body': json['body'],
      'created_at': json['createdAt'],
      'updated_at': json['updatedAt'],
      'tags': json['tags'],
      'linked_note_ids': json['linkedNoteIds'],
      'linked_goal_ids': json['linkedGoalIds'],
      'source_url': json['sourceUrl'],
      'note_type': json['noteType'],
    };
  }

  Map<String, dynamic> _dbRowToNoteJson(Map<String, dynamic> row) => {
        'id': row['id'],
        'title': row['title'],
        'body': row['body'],
        'createdAt': row['created_at'],
        'updatedAt': row['updated_at'],
        'tags': row['tags'],
        'linkedNoteIds': row['linked_note_ids'],
        'linkedGoalIds': row['linked_goal_ids'],
        'sourceUrl': row['source_url'],
        'noteType': row['note_type'],
      };

  // ── Resources ──────────────────────────────────────────────────────────────

  Future<List<Resource>> getResources() async {
    if (_db == null) return [];
    final rows = await _db!.query('resources', orderBy: 'created_at DESC');
    return rows.map((r) => Resource.fromJson(_dbRowToResourceJson(r))).toList();
  }

  Future<void> insertResource(Resource resource) async {
    if (_db == null) return;
    await _db!.insert(
      'resources',
      _resourceToDbRow(resource),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateResource(Resource resource) async {
    if (_db == null) return;
    await _db!.update(
      'resources',
      _resourceToDbRow(resource),
      where: 'id = ?',
      whereArgs: [resource.id],
    );
  }

  Future<void> deleteResource(String id) async {
    if (_db == null) return;
    await _db!.delete('resources', where: 'id = ?', whereArgs: [id]);
  }

  Map<String, dynamic> _resourceToDbRow(Resource r) {
    final json = r.toJson();
    return {
      'id': json['id'],
      'title': json['title'],
      'url': json['url'],
      'author': json['author'],
      'resource_type': json['resourceType'],
      'tags': json['tags'],
      'notes': json['notes'],
      'associated_goal_ids': json['associatedGoalIds'],
      'read_status': json['readStatus'],
      'created_at': json['createdAt'],
    };
  }

  Map<String, dynamic> _dbRowToResourceJson(Map<String, dynamic> row) => {
        'id': row['id'],
        'title': row['title'],
        'url': row['url'],
        'author': row['author'],
        'resourceType': row['resource_type'],
        'tags': row['tags'],
        'notes': row['notes'],
        'associatedGoalIds': row['associated_goal_ids'],
        'readStatus': row['read_status'],
        'createdAt': row['created_at'],
      };

  // ── Review Cards ───────────────────────────────────────────────────────────

  Future<List<ReviewCard>> getReviewCards() async {
    if (_db == null) return [];
    final rows = await _db!.query('review_cards');
    return rows.map((r) => ReviewCard.fromJson(_dbRowToCardJson(r))).toList();
  }

  Future<void> insertCard(ReviewCard card) async {
    if (_db == null) return;
    await _db!.insert(
      'review_cards',
      _cardToDbRow(card),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCard(ReviewCard card) async {
    if (_db == null) return;
    await _db!.update(
      'review_cards',
      _cardToDbRow(card),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteCard(String id) async {
    if (_db == null) return;
    await _db!.delete('review_cards', where: 'id = ?', whereArgs: [id]);
  }

  Map<String, dynamic> _cardToDbRow(ReviewCard c) => {
        'id': c.id,
        'front': c.front,
        'back': c.back,
        'note_id': c.noteId,
        'created_at': c.createdAt.toIso8601String(),
        'next_review_date': c.nextReviewDate.toIso8601String(),
        'interval_days': c.intervalDays,
        'ease_factor': c.easeFactor,
        'repetition_count': c.repetitionCount,
      };

  Map<String, dynamic> _dbRowToCardJson(Map<String, dynamic> row) => {
        'id': row['id'],
        'front': row['front'],
        'back': row['back'],
        'noteId': row['note_id'],
        'createdAt': row['created_at'],
        'nextReviewDate': row['next_review_date'],
        'intervalDays': row['interval_days'],
        'easeFactor': row['ease_factor'],
        'repetitionCount': row['repetition_count'],
      };

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
