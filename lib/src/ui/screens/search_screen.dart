import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/education_goal.dart';
import '../../models/knowledge_note.dart';
import '../../models/resource.dart';
import '../providers/education_provider.dart';
import '../theme/app_theme.dart';
import 'goal_detail_screen.dart';
import 'note_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white70,
          decoration: const InputDecoration(
            hintText: 'Search notes, goals, resources…',
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.trim().isEmpty
          ? _buildEmptyPrompt()
          : Consumer<EducationProvider>(
              builder: (context, provider, child) {
                final results = provider.globalSearch(_query);
                final notes =
                    (results['notes'] as List).cast<KnowledgeNote>();
                final goals =
                    (results['goals'] as List).cast<EducationGoal>();
                final resources =
                    (results['resources'] as List).cast<Resource>();

                if (notes.isEmpty && goals.isEmpty && resources.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results for "$_query"',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  children: [
                    if (notes.isNotEmpty) ...[
                      _SectionHeader(
                        icon: Icons.note,
                        label: 'Notes (${notes.length})',
                      ),
                      ...notes.map(
                        (n) => _NoteResultTile(
                          note: n,
                          query: _query,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => NoteDetailScreen(noteId: n.id),
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (goals.isNotEmpty) ...[
                      _SectionHeader(
                        icon: Icons.school,
                        label: 'Goals (${goals.length})',
                      ),
                      ...goals.map(
                        (g) => _GoalResultTile(
                          goal: g,
                          query: _query,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  GoalDetailScreen(goalId: g.id),
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (resources.isNotEmpty) ...[
                      _SectionHeader(
                        icon: Icons.library_books,
                        label: 'Resources (${resources.length})',
                      ),
                      ...resources.map(
                        (r) => _ResourceResultTile(
                          resource: r,
                          query: _query,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEmptyPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Search across notes, goals, and resources',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteResultTile extends StatelessWidget {
  final KnowledgeNote note;
  final String query;
  final VoidCallback onTap;

  const _NoteResultTile({
    required this.note,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.note, color: AppTheme.primaryColor),
      title: _HighlightText(text: note.title, query: query),
      subtitle: note.body.isNotEmpty
          ? _HighlightText(text: _truncate(note.body, 80), query: query)
          : null,
      trailing: Text(
        note.noteType.label,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      onTap: onTap,
    );
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}…';
  }
}

class _GoalResultTile extends StatelessWidget {
  final EducationGoal goal;
  final String query;
  final VoidCallback onTap;

  const _GoalResultTile({
    required this.goal,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        goal.isCompleted ? Icons.check_circle : Icons.school,
        color: goal.isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
      ),
      title: _HighlightText(text: goal.title, query: query),
      subtitle: _HighlightText(
        text: goal.description.length > 80
            ? '${goal.description.substring(0, 80)}…'
            : goal.description,
        query: query,
      ),
      trailing: goal.isCompleted
          ? const Text(
              'Completed',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.successColor,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}

class _ResourceResultTile extends StatelessWidget {
  final Resource resource;
  final String query;

  const _ResourceResultTile({required this.resource, required this.query});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.library_books, color: AppTheme.secondaryColor),
      title: _HighlightText(text: resource.title, query: query),
      subtitle: resource.author != null
          ? Text(resource.author!, style: AppTextStyles.caption)
          : null,
      trailing: Text(
        resource.resourceType.label,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }
}

class _HighlightText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return Text(text);

    final lower = text.toLowerCase();
    final queryLower = query.toLowerCase();
    final index = lower.indexOf(queryLower);

    if (index == -1) return Text(text);

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          if (index > 0)
            TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: const TextStyle(
              backgroundColor: Color(0xFFFFEB3B),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (index + query.length < text.length)
            TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }
}
