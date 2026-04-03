import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/resource.dart';
import '../providers/education_provider.dart';
import '../theme/app_theme.dart';

class ResourceFormDialog extends StatefulWidget {
  final Resource? resource;

  const ResourceFormDialog({super.key, this.resource});

  bool get isEditing => resource != null;

  @override
  State<ResourceFormDialog> createState() => _ResourceFormDialogState();
}

class _ResourceFormDialogState extends State<ResourceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _urlController;
  late TextEditingController _authorController;
  late TextEditingController _notesController;
  late TextEditingController _tagInputController;
  late ResourceType _selectedType;
  late ReadStatus _selectedStatus;
  late List<String> _tags;
  late List<String> _associatedGoalIds;

  @override
  void initState() {
    super.initState();
    final r = widget.resource;
    _titleController = TextEditingController(text: r?.title ?? '');
    _urlController = TextEditingController(text: r?.url ?? '');
    _authorController = TextEditingController(text: r?.author ?? '');
    _notesController = TextEditingController(text: r?.notes ?? '');
    _tagInputController = TextEditingController();
    _selectedType = r?.resourceType ?? ResourceType.article;
    _selectedStatus = r?.readStatus ?? ReadStatus.unread;
    _tags = List.from(r?.tags ?? []);
    _associatedGoalIds = List.from(r?.associatedGoalIds ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _authorController.dispose();
    _notesController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildTypeSelector(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          prefixIcon: Icon(Icons.title),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _authorController,
                        decoration: const InputDecoration(
                          labelText: 'Author / Creator (Optional)',
                          prefixIcon: Icon(Icons.person),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          labelText: 'URL (Optional)',
                          prefixIcon: Icon(Icons.link),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 16),
                      _buildStatusSelector(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          prefixIcon: Icon(Icons.notes),
                          alignLabelWithHint: true,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 3,
                        minLines: 2,
                      ),
                      const SizedBox(height: 16),
                      _buildTagsInput(),
                      const SizedBox(height: 16),
                      _buildGoalLinker(context),
                      const SizedBox(height: 24),
                      _buildActions(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
      child: Row(
        children: [
          Icon(
            widget.isEditing ? Icons.edit : Icons.add_circle,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Text(
            widget.isEditing ? 'Edit Resource' : 'New Resource',
            style: AppTextStyles.heading2,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resource Type',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ResourceType.values.map((type) {
            final isSelected = _selectedType == type;
            return FilterChip(
              label: Text(type.label, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedType = type),
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ReadStatus.values.map((status) {
            final isSelected = _selectedStatus == status;
            return FilterChip(
              label: Text(status.label, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedStatus = status),
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _tags
                .map(
                  (tag) => Chip(
                    label: Text('#$tag', style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => setState(() => _tags.remove(tag)),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagInputController,
                decoration: const InputDecoration(
                  hintText: 'Add a tag',
                  prefixIcon: Icon(Icons.tag, size: 18),
                  isDense: true,
                ),
                onSubmitted: _addTag,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _addTag(_tagInputController.text),
              child: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }

  void _addTag(String value) {
    final tag = value.trim().replaceAll(RegExp(r'[^a-zA-Z0-9\-_]'), '');
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
    }
    _tagInputController.clear();
  }

  Widget _buildGoalLinker(BuildContext context) {
    final provider = context.read<EducationProvider>();
    final goals =
        provider.allGoals.where((g) => !g.isCompleted).toList();

    if (goals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Link to Goals (Optional)',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        ...goals.map(
          (goal) => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(goal.title, style: const TextStyle(fontSize: 14)),
            value: _associatedGoalIds.contains(goal.id),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _associatedGoalIds.add(goal.id);
                } else {
                  _associatedGoalIds.remove(goal.id);
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _save,
          child: Text(widget.isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<EducationProvider>();
    final title = _titleController.text.trim();
    final url = _urlController.text.trim();
    final author = _authorController.text.trim();
    final notes = _notesController.text.trim();

    if (widget.isEditing) {
      provider.updateResource(
        widget.resource!.id,
        title: title,
        url: url,
        author: author.isNotEmpty ? author : null,
        clearAuthor: author.isEmpty,
        resourceType: _selectedType,
        tags: _tags,
        notes: notes,
        associatedGoalIds: _associatedGoalIds,
        readStatus: _selectedStatus,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resource updated')),
      );
    } else {
      provider.createResource(
        title: title,
        url: url,
        author: author.isNotEmpty ? author : null,
        resourceType: _selectedType,
        tags: _tags,
        notes: notes,
        associatedGoalIds: _associatedGoalIds,
        readStatus: _selectedStatus,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resource added'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }

    Navigator.of(context).pop();
  }
}
