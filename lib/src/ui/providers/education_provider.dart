import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../models/activity.dart';
import '../../models/education_goal.dart';
import '../../models/knowledge_note.dart';
import '../../models/resource.dart';
import '../../models/review_card.dart';
import '../../models/weekly_plan.dart';
import '../../services/database_service.dart';
import '../../services/education_goal_service.dart';
import '../../services/knowledge_note_service.dart';
import '../../services/resource_service.dart';
import '../../services/spaced_repetition_service.dart';
import '../../services/weekly_plan_service.dart';

export '../../models/knowledge_note.dart' show NoteType, NoteTypeExtension;
export '../../models/resource.dart'
    show Resource, ResourceType, ResourceTypeExtension, ReadStatus, ReadStatusExtension;
export '../../models/review_card.dart' show ReviewCard;
export '../../services/spaced_repetition_service.dart' show ReviewRating;

enum GoalFilter { all, active, completed }

class EducationProvider extends ChangeNotifier {
  final EducationGoalService _goalService = EducationGoalService();
  final WeeklyPlanService _planService = WeeklyPlanService();
  final KnowledgeNoteService _noteService = KnowledgeNoteService();
  final ResourceService _resourceService = ResourceService();
  final SpacedRepetitionService _srService = SpacedRepetitionService();
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();

  GoalFilter _currentFilter = GoalFilter.active;
  DateTime _selectedWeek = DateTime.now();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  GoalFilter get currentFilter => _currentFilter;
  DateTime get selectedWeek => _selectedWeek;

  // ── Initialization ─────────────────────────────────────────────────────────

  Future<void> initialize() async {
    try {
      await _databaseService.initialize();

      _goalService.attachDatabase(_databaseService);
      _planService.attachDatabase(_databaseService);
      _noteService.attachDatabase(_databaseService);
      _resourceService.attachDatabase(_databaseService);
      _srService.attachDatabase(_databaseService);

      final goals = await _databaseService.getGoals();
      _goalService.loadAll(goals);

      final plans = await _databaseService.getWeeklyPlans();
      _planService.loadAll(plans);

      final notes = await _databaseService.getKnowledgeNotes();
      _noteService.loadAll(notes);

      final resources = await _databaseService.getResources();
      _resourceService.loadAll(resources);

      final cards = await _databaseService.getReviewCards();
      _srService.loadAll(cards);
    } catch (_) {
      // Fall back to empty in-memory state if the database is unavailable
      // (e.g., in test environments or unsupported platforms)
    }
    _isInitialized = true;
    notifyListeners();
  }

  // ── Goal operations ────────────────────────────────────────────────────────

  List<EducationGoal> get goals {
    switch (_currentFilter) {
      case GoalFilter.all:
        return _goalService.getAllGoals();
      case GoalFilter.active:
        return _goalService.getActiveGoals();
      case GoalFilter.completed:
        return _goalService.getCompletedGoals();
    }
  }

  List<EducationGoal> get allGoals => _goalService.getAllGoals();

  EducationGoal? getGoal(String id) => _goalService.getGoal(id);

  int get totalGoals => _goalService.totalGoals;
  int get completedGoalsCount => _goalService.completedGoalsCount;
  double get goalsCompletionPercentage => _goalService.completionPercentage;

  void setFilter(GoalFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  EducationGoal createGoal({
    required String title,
    required String description,
    DateTime? targetDate,
    List<String>? tags,
  }) {
    final goal = _goalService.createGoal(
      id: _uuid.v4(),
      title: title,
      description: description,
      targetDate: targetDate,
      tags: tags,
    );
    notifyListeners();
    return goal;
  }

  bool updateGoal(
    String id, {
    String? title,
    String? description,
    DateTime? targetDate,
    bool? isCompleted,
    List<String>? tags,
    List<String>? linkedNoteIds,
  }) {
    final goal = _goalService.getGoal(id);
    if (goal == null) return false;

    final updated = goal.copyWith(
      title: title,
      description: description,
      targetDate: targetDate,
      isCompleted: isCompleted,
      tags: tags,
      linkedNoteIds: linkedNoteIds,
    );
    final success = _goalService.updateGoal(id, updated);
    if (success) notifyListeners();
    return success;
  }

  bool completeGoal(String id) {
    final success = _goalService.completeGoal(id);
    if (success) notifyListeners();
    return success;
  }

  bool deleteGoal(String id) {
    final success = _goalService.deleteGoal(id);
    if (success) notifyListeners();
    return success;
  }

  // ── Weekly plan operations ─────────────────────────────────────────────────

  List<WeeklyPlan> get allPlans => _planService.getAllPlans();

  WeeklyPlan? get currentWeekPlan => _planService.getPlanForWeek(_selectedWeek);

  WeeklyPlan? getPlan(String id) => _planService.getPlan(id);

  void setSelectedWeek(DateTime date) {
    _selectedWeek = date;
    notifyListeners();
  }

  void navigateToPreviousWeek() {
    _selectedWeek = _selectedWeek.subtract(const Duration(days: 7));
    notifyListeners();
  }

  void navigateToNextWeek() {
    _selectedWeek = _selectedWeek.add(const Duration(days: 7));
    notifyListeners();
  }

  void navigateToCurrentWeek() {
    _selectedWeek = DateTime.now();
    notifyListeners();
  }

  WeeklyPlan createPlan({
    required String title,
    required DateTime weekStartDate,
  }) {
    final plan = _planService.createPlan(
      id: _uuid.v4(),
      title: title,
      weekStartDate: weekStartDate,
    );
    notifyListeners();
    return plan;
  }

  WeeklyPlan getOrCreatePlanForWeek(DateTime date) {
    var plan = _planService.getPlanForWeek(date);
    if (plan == null) {
      final monday = _normalizeToMonday(date);
      plan = createPlan(
        title: 'Week of ${_formatDate(monday)}',
        weekStartDate: monday,
      );
    }
    return plan;
  }

  DateTime _normalizeToMonday(DateTime date) {
    final weekday = date.weekday;
    final daysToSubtract = weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysToSubtract));
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  bool deletePlan(String id) {
    final success = _planService.deletePlan(id);
    if (success) notifyListeners();
    return success;
  }

  // ── Activity operations ────────────────────────────────────────────────────

  Activity addActivity({
    required String planId,
    required String title,
    String? description,
    String? goalId,
    required int durationMinutes,
    required DateTime scheduledTime,
  }) {
    final activity = Activity(
      id: _uuid.v4(),
      title: title,
      description: description,
      goalId: goalId,
      durationMinutes: durationMinutes,
      scheduledTime: scheduledTime,
    );
    _planService.addActivityToPlan(planId, activity);
    notifyListeners();
    return activity;
  }

  bool removeActivity(String planId, String activityId) {
    final success = _planService.removeActivityFromPlan(planId, activityId);
    if (success) notifyListeners();
    return success;
  }

  bool completeActivity(String planId, String activityId) {
    final success = _planService.completeActivity(planId, activityId);
    if (success) notifyListeners();
    return success;
  }

  bool toggleActivityCompletion(String planId, String activityId) {
    final success = _planService.toggleActivityCompletion(planId, activityId);
    if (success) notifyListeners();
    return success;
  }

  List<Activity> getActivitiesForGoal(String goalId) {
    return _planService.getActivitiesForGoal(goalId);
  }

  // ── Progress calculations ──────────────────────────────────────────────────

  double getGoalProgress(String goalId) {
    final activities = getActivitiesForGoal(goalId);
    if (activities.isEmpty) return 0.0;
    final completed = activities.where((a) => a.isCompleted).length;
    return (completed / activities.length) * 100;
  }

  int getTotalTimeSpentOnGoal(String goalId) {
    final activities = getActivitiesForGoal(goalId);
    return activities
        .where((a) => a.isCompleted)
        .fold(0, (sum, a) => sum + a.durationMinutes);
  }

  // ── Knowledge Note operations ──────────────────────────────────────────────

  List<KnowledgeNote> get allNotes => _noteService.getAllNotes();

  List<KnowledgeNote> get fleetingNotes => _noteService.getFleetingNotes();

  KnowledgeNote? getNote(String id) => _noteService.getNote(id);

  List<KnowledgeNote> getNotesByType(NoteType type) =>
      _noteService.getNotesByType(type);

  List<KnowledgeNote> getNotesLinkedToGoal(String goalId) =>
      _noteService.getNotesLinkedToGoal(goalId);

  List<KnowledgeNote> getLinkedNotes(String noteId) =>
      _noteService.getLinkedNotes(noteId);

  List<String> get allNoteTags => _noteService.getAllTags();

  Map<String, int> get noteTagCounts => _noteService.getTagCounts();

  Map<NoteType, int> get noteCountsByType => _noteService.noteCountsByType;

  int get totalNotes => _noteService.totalNotes;

  KnowledgeNote createNote({
    required String title,
    String body = '',
    List<String>? tags,
    List<String>? linkedNoteIds,
    List<String>? linkedGoalIds,
    String? sourceUrl,
    NoteType noteType = NoteType.fleeting,
  }) {
    final note = _noteService.createNote(
      id: _uuid.v4(),
      title: title,
      body: body,
      tags: tags,
      linkedNoteIds: linkedNoteIds,
      linkedGoalIds: linkedGoalIds,
      sourceUrl: sourceUrl,
      noteType: noteType,
    );
    notifyListeners();
    return note;
  }

  bool updateNote(
    String id, {
    String? title,
    String? body,
    List<String>? tags,
    List<String>? linkedNoteIds,
    List<String>? linkedGoalIds,
    String? sourceUrl,
    NoteType? noteType,
    bool clearSourceUrl = false,
  }) {
    final note = _noteService.getNote(id);
    if (note == null) return false;

    final updated = note.copyWith(
      title: title,
      body: body,
      tags: tags,
      linkedNoteIds: linkedNoteIds,
      linkedGoalIds: linkedGoalIds,
      sourceUrl: sourceUrl,
      noteType: noteType,
      clearSourceUrl: clearSourceUrl,
      updatedAt: DateTime.now(),
    );
    final success = _noteService.updateNote(id, updated);
    if (success) notifyListeners();
    return success;
  }

  bool deleteNote(String id) {
    final success = _noteService.deleteNote(id);
    if (success) notifyListeners();
    return success;
  }

  List<KnowledgeNote> searchNotes(String query) => _noteService.search(query);

  List<KnowledgeNote> getNotesCreatedSince(DateTime since) =>
      _noteService.getNotesCreatedSince(since);

  // ── Resource operations ────────────────────────────────────────────────────

  List<Resource> get allResources => _resourceService.getAllResources();

  Resource? getResource(String id) => _resourceService.getResource(id);

  List<Resource> getResourcesByType(ResourceType type) =>
      _resourceService.getResourcesByType(type);

  List<Resource> searchResources(String query) => _resourceService.search(query);

  List<String> get allResourceTags => _resourceService.getAllTags();

  int get totalResources => _resourceService.totalResources;

  Resource createResource({
    required String title,
    String url = '',
    String? author,
    ResourceType resourceType = ResourceType.article,
    List<String>? tags,
    String notes = '',
    List<String>? associatedGoalIds,
    ReadStatus readStatus = ReadStatus.unread,
  }) {
    final resource = _resourceService.createResource(
      id: _uuid.v4(),
      title: title,
      url: url,
      author: author,
      resourceType: resourceType,
      tags: tags,
      notes: notes,
      associatedGoalIds: associatedGoalIds,
      readStatus: readStatus,
    );
    notifyListeners();
    return resource;
  }

  bool updateResource(
    String id, {
    String? title,
    String? url,
    String? author,
    ResourceType? resourceType,
    List<String>? tags,
    String? notes,
    List<String>? associatedGoalIds,
    ReadStatus? readStatus,
    bool clearAuthor = false,
  }) {
    final resource = _resourceService.getResource(id);
    if (resource == null) return false;

    final updated = resource.copyWith(
      title: title,
      url: url,
      author: author,
      resourceType: resourceType,
      tags: tags,
      notes: notes,
      associatedGoalIds: associatedGoalIds,
      readStatus: readStatus,
      clearAuthor: clearAuthor,
    );
    final success = _resourceService.updateResource(id, updated);
    if (success) notifyListeners();
    return success;
  }

  bool deleteResource(String id) {
    final success = _resourceService.deleteResource(id);
    if (success) notifyListeners();
    return success;
  }

  bool updateResourceStatus(String id, ReadStatus status) {
    final success = _resourceService.updateReadStatus(id, status);
    if (success) notifyListeners();
    return success;
  }

  // ── Review Card operations ─────────────────────────────────────────────────

  List<ReviewCard> get allCards => _srService.getAllCards();

  List<ReviewCard> get dueCards => _srService.getDueCards();

  int get dueCardCount => _srService.dueCount;

  int get totalCards => _srService.totalCards;

  ReviewCard? getCard(String id) => _srService.getCard(id);

  ReviewCard createReviewCard({
    required String front,
    required String back,
    String? noteId,
  }) {
    final card = _srService.createCard(
      id: _uuid.v4(),
      front: front,
      back: back,
      noteId: noteId,
    );
    notifyListeners();
    return card;
  }

  ReviewCard createCardFromNote(String noteId) {
    final note = _noteService.getNote(noteId);
    if (note == null) {
      throw ArgumentError('Note with id $noteId not found');
    }
    final card = _srService.createCardFromNote(_uuid.v4(), note);
    notifyListeners();
    return card;
  }

  ReviewCard? recordReview(String cardId, ReviewRating rating) {
    final updated = _srService.recordReview(cardId, rating);
    if (updated != null) notifyListeners();
    return updated;
  }

  bool deleteReviewCard(String id) {
    final success = _srService.deleteCard(id);
    if (success) notifyListeners();
    return success;
  }

  // ── Global search ──────────────────────────────────────────────────────────

  /// Returns a map with lists of matching notes, goals, and resources.
  Map<String, List<dynamic>> globalSearch(String query) {
    if (query.trim().isEmpty) {
      return {'notes': [], 'goals': [], 'resources': []};
    }
    return {
      'notes': _noteService.search(query),
      'goals': _goalService.getAllGoals().where((g) {
        final lower = query.toLowerCase();
        return g.title.toLowerCase().contains(lower) ||
            g.description.toLowerCase().contains(lower);
      }).toList(),
      'resources': _resourceService.search(query),
    };
  }

  // ── Dashboard / Analytics ──────────────────────────────────────────────────

  int get currentStreakDays {
    int streak = 0;
    var day = DateTime.now();
    while (true) {
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));
      final hasNote = _noteService
          .getAllNotes()
          .any((n) => n.createdAt.isAfter(start) && n.createdAt.isBefore(end));
      final hasActivity = _planService.getAllPlans().any(
        (p) => p.activities.any(
          (a) =>
              a.isCompleted &&
              a.scheduledTime.isAfter(start) &&
              a.scheduledTime.isBefore(end),
        ),
      );
      if (hasNote || hasActivity) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
