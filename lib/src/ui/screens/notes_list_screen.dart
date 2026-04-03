import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/knowledge_note.dart';
import '../providers/education_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import 'note_detail_screen.dart';
import 'note_form_dialog.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  NoteType? _selectedType;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _toggleSearch,
            tooltip: 'Search notes',
          ),
        ],
        bottom: _searchQuery.isNotEmpty || _searchController.text.isNotEmpty
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search notes…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              )
            : null,
      ),
      body: Consumer<EducationProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildTypeFilterChips(),
              Expanded(
                child: _buildNotesList(provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateNoteDialog(context),
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTypeFilterChips() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _TypeChip(
            label: 'All',
            isSelected: _selectedType == null,
            onTap: () => setState(() => _selectedType = null),
          ),
          const SizedBox(width: 8),
          ...NoteType.values.map((type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _TypeChip(
                  label: type.label,
                  isSelected: _selectedType == type,
                  color: _noteTypeColor(type),
                  onTap: () => setState(
                    () => _selectedType = _selectedType == type ? null : type,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildNotesList(EducationProvider provider) {
    List<KnowledgeNote> notes;

    if (_searchQuery.isNotEmpty) {
      notes = provider.searchNotes(_searchQuery);
    } else if (_selectedType != null) {
      notes = provider.getNotesByType(_selectedType!);
    } else {
      notes = provider.allNotes;
    }

    if (notes.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return const EmptyState(
          icon: Icons.search_off,
          title: 'No notes found',
          subtitle: 'Try a different search term.',
        );
      }
      return EmptyState(
        icon: Icons.note_outlined,
        title: 'No notes yet',
        subtitle:
            'Capture your first idea, insight, or reference note to build your knowledge base.',
        actionLabel: 'Add Note',
        onAction: () => _showCreateNoteDialog(context),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return _NoteCard(
          note: notes[index],
          onTap: () => _navigateToDetail(context, notes[index].id),
        );
      },
    );
  }

  void _toggleSearch() {
    if (_searchQuery.isNotEmpty) {
      _clearSearch();
    } else {
      setState(() {
        _searchQuery = ' ';
        _searchController.clear();
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _navigateToDetail(BuildContext context, String noteId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NoteDetailScreen(noteId: noteId)),
    );
  }

  void _showCreateNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      isScrollControlled: true,
      builder: (_) => const NoteFormDialog(),
    );
  }

  Color _noteTypeColor(NoteType type) {
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
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryColor;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: effectiveColor.withValues(alpha: 0.2),
      checkmarkColor: effectiveColor,
      labelStyle: TextStyle(
        color: isSelected ? effectiveColor : null,
        fontWeight: isSelected ? FontWeight.w600 : null,
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final KnowledgeNote note;
  final VoidCallback onTap;

  const _NoteCard({required this.note, required this.onTap});

  Color get _typeColor {
    switch (note.noteType) {
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      note.noteType.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _typeColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(note.updatedAt),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.title,
                style: AppTextStyles.heading3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (note.body.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  note.body,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: note.tags
                      .take(4)
                      .map((tag) => _TagChip(tag: tag))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        '#$tag',
        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
      ),
    );
  }
}
