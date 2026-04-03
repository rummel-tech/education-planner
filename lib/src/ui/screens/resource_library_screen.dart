import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/resource.dart';
import '../providers/education_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import 'resource_form_dialog.dart';

class ResourceLibraryScreen extends StatefulWidget {
  const ResourceLibraryScreen({super.key});

  @override
  State<ResourceLibraryScreen> createState() => _ResourceLibraryScreenState();
}

class _ResourceLibraryScreenState extends State<ResourceLibraryScreen> {
  ResourceType? _selectedType;
  ReadStatus? _selectedStatus;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Library'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.search_off : Icons.search),
            onPressed: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchQuery = '';
                _searchController.clear();
              }
            }),
          ),
        ],
        bottom: _showSearch
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search resources…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
              )
            : null,
      ),
      body: Consumer<EducationProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildTypeFilter(),
              _buildStatusFilter(),
              Expanded(child: _buildResourceList(provider)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        tooltip: 'Add Resource',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTypeFilter() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _FilterChipItem(
            label: 'All Types',
            isSelected: _selectedType == null,
            onTap: () => setState(() => _selectedType = null),
          ),
          const SizedBox(width: 8),
          ...ResourceType.values.map(
            (t) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChipItem(
                label: t.label,
                icon: _resourceTypeIcon(t),
                isSelected: _selectedType == t,
                onTap: () => setState(
                  () => _selectedType = _selectedType == t ? null : t,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          _FilterChipItem(
            label: 'All Statuses',
            isSelected: _selectedStatus == null,
            onTap: () => setState(() => _selectedStatus = null),
          ),
          const SizedBox(width: 8),
          ...ReadStatus.values.map(
            (s) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChipItem(
                label: s.label,
                isSelected: _selectedStatus == s,
                color: _statusColor(s),
                onTap: () => setState(
                  () => _selectedStatus = _selectedStatus == s ? null : s,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceList(EducationProvider provider) {
    List<Resource> resources;

    if (_searchQuery.isNotEmpty) {
      resources = provider.searchResources(_searchQuery);
    } else if (_selectedType != null) {
      resources = provider.getResourcesByType(_selectedType!);
    } else {
      resources = provider.allResources;
    }

    if (_selectedStatus != null && _searchQuery.isEmpty) {
      resources = resources
          .where((r) => r.readStatus == _selectedStatus)
          .toList();
    }

    if (resources.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return const EmptyState(
          icon: Icons.search_off,
          title: 'No resources found',
          subtitle: 'Try a different search term.',
        );
      }
      return EmptyState(
        icon: Icons.library_books_outlined,
        title: 'No resources yet',
        subtitle:
            'Add books, articles, videos, and courses to your knowledge library.',
        actionLabel: 'Add Resource',
        onAction: () => _showCreateDialog(context),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return _ResourceCard(
          resource: resource,
          onTap: () => _showResourceOptions(context, resource),
          onStatusChanged: (status) {
            context.read<EducationProvider>().updateResourceStatus(
                  resource.id,
                  status,
                );
          },
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ResourceFormDialog(),
    );
  }

  void _showResourceOptions(BuildContext context, Resource resource) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => ResourceFormDialog(resource: resource),
                );
              },
            ),
            ...ReadStatus.values.map(
              (status) => status == resource.readStatus
                  ? const SizedBox.shrink()
                  : ListTile(
                      leading: Icon(
                        _statusIcon(status),
                        color: _statusColor(status),
                      ),
                      title: Text('Mark as ${status.label}'),
                      onTap: () {
                        context
                            .read<EducationProvider>()
                            .updateResourceStatus(resource.id, status);
                        Navigator.of(context).pop();
                      },
                    ),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.errorColor),
              title: const Text(
                'Delete',
                style: TextStyle(color: AppTheme.errorColor),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _confirmDelete(context, resource.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String resourceId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Resource'),
        content:
            const Text('Are you sure you want to delete this resource?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<EducationProvider>().deleteResource(resourceId);
              Navigator.of(context).pop();
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _resourceTypeIcon(ResourceType type) {
    switch (type) {
      case ResourceType.book:
        return Icons.book;
      case ResourceType.article:
        return Icons.article;
      case ResourceType.video:
        return Icons.video_library;
      case ResourceType.course:
        return Icons.school;
      case ResourceType.podcast:
        return Icons.podcasts;
      case ResourceType.other:
        return Icons.folder;
    }
  }

  Color _statusColor(ReadStatus status) {
    switch (status) {
      case ReadStatus.unread:
        return Colors.grey;
      case ReadStatus.inProgress:
        return AppTheme.warningColor;
      case ReadStatus.completed:
        return AppTheme.successColor;
    }
  }

  IconData _statusIcon(ReadStatus status) {
    switch (status) {
      case ReadStatus.unread:
        return Icons.radio_button_unchecked;
      case ReadStatus.inProgress:
        return Icons.timelapse;
      case ReadStatus.completed:
        return Icons.check_circle;
    }
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryColor;
    return FilterChip(
      avatar: icon != null
          ? Icon(icon, size: 16, color: isSelected ? effectiveColor : null)
          : null,
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: effectiveColor.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? effectiveColor : null,
        fontWeight: isSelected ? FontWeight.w600 : null,
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final Resource resource;
  final VoidCallback onTap;
  final ValueChanged<ReadStatus> onStatusChanged;

  const _ResourceCard({
    required this.resource,
    required this.onTap,
    required this.onStatusChanged,
  });

  IconData get _typeIcon {
    switch (resource.resourceType) {
      case ResourceType.book:
        return Icons.book;
      case ResourceType.article:
        return Icons.article;
      case ResourceType.video:
        return Icons.video_library;
      case ResourceType.course:
        return Icons.school;
      case ResourceType.podcast:
        return Icons.podcasts;
      case ResourceType.other:
        return Icons.folder;
    }
  }

  Color get _statusColor {
    switch (resource.readStatus) {
      case ReadStatus.unread:
        return Colors.grey;
      case ReadStatus.inProgress:
        return AppTheme.warningColor;
      case ReadStatus.completed:
        return AppTheme.successColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_typeIcon, color: AppTheme.primaryColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      style: AppTextStyles.heading3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (resource.author != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        resource.author!,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            resource.readStatus.label,
                            style: TextStyle(
                              fontSize: 11,
                              color: _statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            resource.resourceType.label,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (resource.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        children: resource.tags
                            .take(3)
                            .map(
                              (t) => Text(
                                '#$t',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
