import '../models/resource.dart';
import 'database_service.dart';

/// Service for managing learning resources
class ResourceService {
  final Map<String, Resource> _resources = {};
  DatabaseService? _db;

  void attachDatabase(DatabaseService db) {
    _db = db;
  }

  void loadAll(List<Resource> resources) {
    _resources.clear();
    for (final resource in resources) {
      _resources[resource.id] = resource;
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Resource createResource({
    required String id,
    required String title,
    String url = '',
    String? author,
    ResourceType resourceType = ResourceType.article,
    List<String>? tags,
    String notes = '',
    List<String>? associatedGoalIds,
    ReadStatus readStatus = ReadStatus.unread,
  }) {
    final resource = Resource(
      id: id,
      title: title,
      url: url,
      author: author,
      resourceType: resourceType,
      tags: tags,
      notes: notes,
      associatedGoalIds: associatedGoalIds,
      readStatus: readStatus,
      createdAt: DateTime.now(),
    );
    _resources[id] = resource;
    _db?.insertResource(resource);
    return resource;
  }

  Resource? getResource(String id) => _resources[id];

  List<Resource> getAllResources() {
    final resources = _resources.values.toList();
    resources.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return resources;
  }

  List<Resource> getResourcesByType(ResourceType type) {
    return _resources.values
        .where((r) => r.resourceType == type)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Resource> getResourcesByStatus(ReadStatus status) {
    return _resources.values
        .where((r) => r.readStatus == status)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Resource> getResourcesByTag(String tag) {
    return _resources.values
        .where((r) => r.tags.contains(tag))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Resource> getResourcesForGoal(String goalId) {
    return _resources.values
        .where((r) => r.associatedGoalIds.contains(goalId))
        .toList();
  }

  bool updateResource(String id, Resource updatedResource) {
    if (!_resources.containsKey(id)) return false;
    _resources[id] = updatedResource;
    _db?.updateResource(updatedResource);
    return true;
  }

  bool updateReadStatus(String id, ReadStatus status) {
    final resource = _resources[id];
    if (resource == null) return false;
    _resources[id] = resource.copyWith(readStatus: status);
    _db?.updateResource(_resources[id]!);
    return true;
  }

  bool deleteResource(String id) {
    final removed = _resources.remove(id) != null;
    if (removed) _db?.deleteResource(id);
    return removed;
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  List<Resource> search(String query) {
    if (query.isEmpty) return getAllResources();
    final lower = query.toLowerCase();
    return _resources.values
        .where((r) =>
            r.title.toLowerCase().contains(lower) ||
            (r.author?.toLowerCase().contains(lower) ?? false) ||
            r.tags.any((t) => t.toLowerCase().contains(lower)) ||
            r.notes.toLowerCase().contains(lower))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ── Tag helpers ────────────────────────────────────────────────────────────

  List<String> getAllTags() {
    final tags = <String>{};
    for (final resource in _resources.values) {
      tags.addAll(resource.tags);
    }
    final sorted = tags.toList()..sort();
    return sorted;
  }

  // ── Stats ──────────────────────────────────────────────────────────────────

  int get totalResources => _resources.length;

  int get completedCount =>
      _resources.values.where((r) => r.readStatus == ReadStatus.completed).length;

  void clear() {
    _resources.clear();
  }
}
