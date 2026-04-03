import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/knowledge_note.dart';
import '../providers/education_provider.dart';
import '../theme/app_theme.dart';

class NoteFormDialog extends StatefulWidget {
  final KnowledgeNote? note;

  const NoteFormDialog({super.key, this.note});

  bool get isEditing => note != null;

  @override
  State<NoteFormDialog> createState() => _NoteFormDialogState();
}

class _NoteFormDialogState extends State<NoteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late TextEditingController _sourceUrlController;
  late TextEditingController _tagInputController;
  late NoteType _selectedType;
  late List<String> _tags;
  late List<String> _linkedGoalIds;

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    _titleController = TextEditingController(text: n?.title ?? '');
    _bodyController = TextEditingController(text: n?.body ?? '');
    _sourceUrlController = TextEditingController(text: n?.sourceUrl ?? '');
    _tagInputController = TextEditingController();
    _selectedType = n?.noteType ?? NoteType.fleeting;
    _tags = List.from(n?.tags ?? []);
    _linkedGoalIds = List.from(n?.linkedGoalIds ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _sourceUrlController.dispose();
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
                        textCapitalization: TextCapitalization.sentences,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bodyController,
                        decoration: const InputDecoration(
                          labelText: 'Body (Markdown supported)',
                          prefixIcon: Icon(Icons.notes),
                          alignLabelWithHint: true,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 6,
                        minLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _sourceUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Source URL (Optional)',
                          prefixIcon: Icon(Icons.link),
                        ),
                        keyboardType: TextInputType.url,
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
            widget.isEditing ? 'Edit Note' : 'New Note',
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
          'Note Type',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: NoteType.values.map((type) {
            final isSelected = _selectedType == type;
            return FilterChip(
              label: Text(type.label),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedType = type),
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                fontSize: 13,
                color: isSelected ? AppTheme.primaryColor : null,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
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
                  hintText: 'Add a tag and press Enter',
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
        const SizedBox(height: 8),
        ...goals.map(
          (goal) => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(goal.title, style: const TextStyle(fontSize: 14)),
            value: _linkedGoalIds.contains(goal.id),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _linkedGoalIds.add(goal.id);
                } else {
                  _linkedGoalIds.remove(goal.id);
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
          child: Text(widget.isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<EducationProvider>();
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final sourceUrl = _sourceUrlController.text.trim();

    if (widget.isEditing) {
      provider.updateNote(
        widget.note!.id,
        title: title,
        body: body,
        tags: _tags,
        linkedGoalIds: _linkedGoalIds,
        noteType: _selectedType,
        sourceUrl: sourceUrl.isNotEmpty ? sourceUrl : null,
        clearSourceUrl: sourceUrl.isEmpty,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note updated')),
      );
    } else {
      provider.createNote(
        title: title,
        body: body,
        tags: _tags,
        linkedGoalIds: _linkedGoalIds,
        noteType: _selectedType,
        sourceUrl: sourceUrl.isNotEmpty ? sourceUrl : null,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note created'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }

    Navigator.of(context).pop();
  }
}
