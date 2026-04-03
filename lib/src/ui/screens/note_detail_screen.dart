import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import '../../models/education_goal.dart';
import '../../models/knowledge_note.dart';
import '../providers/education_provider.dart';
import '../theme/app_theme.dart';
import 'note_form_dialog.dart';

class NoteDetailScreen extends StatelessWidget {
  final String noteId;

  const NoteDetailScreen({super.key, required this.noteId});

  @override
  Widget build(BuildContext context) {
    return Consumer<EducationProvider>(
      builder: (context, provider, child) {
        final note = provider.getNote(noteId);
        if (note == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Note Not Found')),
            body: const Center(child: Text('This note no longer exists.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Note'),
            actions: [
              IconButton(
                icon: const Icon(Icons.style),
                onPressed: () => _createFlashcard(context, provider, note),
                tooltip: 'Create flashcard',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditDialog(context, note),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmation(context, provider),
                tooltip: 'Delete',
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(note),
                if (note.body.isNotEmpty) _buildBody(note),
                if (note.sourceUrl != null && note.sourceUrl!.isNotEmpty)
                  _buildSourceUrl(note),
                if (note.linkedGoalIds.isNotEmpty)
                  _buildLinkedGoals(context, provider, note),
                if (note.linkedNoteIds.isNotEmpty)
                  _buildLinkedNotes(context, provider, note),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(KnowledgeNote note) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _NoteTypeBadge(type: note.noteType),
              const Spacer(),
              Text(
                _formatDate(note.updatedAt),
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(note.title, style: AppTextStyles.heading2),
          if (note.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: note.tags
                  .map((t) => _TagChip(tag: t))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(KnowledgeNote note) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Content', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          MarkdownBody(
            data: note.body,
            styleSheet: MarkdownStyleSheet(
              p: AppTextStyles.body,
              h1: AppTextStyles.heading1,
              h2: AppTextStyles.heading2,
              h3: AppTextStyles.heading3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceUrl(KnowledgeNote note) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.link, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note.sourceUrl!,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                decoration: TextDecoration.underline,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedGoals(
    BuildContext context,
    EducationProvider provider,
    KnowledgeNote note,
  ) {
    final linkedGoals = note.linkedGoalIds
        .map((id) => provider.getGoal(id))
        .whereType<EducationGoal>()
        .toList();

    if (linkedGoals.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Linked Goals', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          ...linkedGoals.map(
            (goal) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.school, color: AppTheme.primaryColor),
              title: Text(goal.title),
              dense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedNotes(
    BuildContext context,
    EducationProvider provider,
    KnowledgeNote note,
  ) {
    final linked = provider.getLinkedNotes(noteId);
    if (linked.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Linked Notes', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          ...linked.map(
            (n) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.note, color: AppTheme.secondaryColor),
              title: Text(n.title),
              dense: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NoteDetailScreen(noteId: n.id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createFlashcard(
    BuildContext context,
    EducationProvider provider,
    KnowledgeNote note,
  ) {
    provider.createCardFromNote(note.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Flashcard created for spaced-repetition review!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showEditDialog(BuildContext context, KnowledgeNote note) {
    showDialog(
      context: context,
      isScrollControlled: true,
      builder: (_) => NoteFormDialog(note: note),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    EducationProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text(
          'Are you sure you want to delete this note? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteNote(noteId);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _NoteTypeBadge extends StatelessWidget {
  final NoteType type;
  const _NoteTypeBadge({required this.type});

  Color get _color {
    switch (type) {
      case NoteType.fleeting:
        return Colors.grey;
      case NoteType.concept:
        return AppTheme.primaryColor;
      case NoteType.reference:
        return AppTheme.secondaryColor;
      case NoteType.question:
        return AppTheme.warningColor;
      case NoteType.insight:
        return AppTheme.successColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        '#$tag',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
      ),
    );
  }
}
