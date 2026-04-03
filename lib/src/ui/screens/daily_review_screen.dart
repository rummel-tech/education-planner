import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/knowledge_note.dart';
import '../providers/education_provider.dart';
import '../theme/app_theme.dart';
import 'knowledge_dashboard_screen.dart';
import 'note_detail_screen.dart';
import 'note_form_dialog.dart';
import 'review_session_screen.dart';

class DailyReviewScreen extends StatelessWidget {
  const DailyReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Dashboard',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const KnowledgeDashboardScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<EducationProvider>(
        builder: (context, provider, child) {
          final dueCards = provider.dueCards;
          final fleetingNotes = provider.fleetingNotes;
          final recentNotes = provider.getNotesCreatedSince(
            DateTime.now().subtract(const Duration(days: 7)),
          );

          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                _buildReviewSection(context, dueCards.length),
                const SizedBox(height: 8),
                _buildInboxSection(context, provider, fleetingNotes),
                const SizedBox(height: 8),
                _buildWeeklyStats(context, provider, recentNotes),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickCapture(context),
        icon: const Icon(Icons.edit),
        label: const Text('Quick Capture'),
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context, int dueCount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.style, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Spaced Repetition',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (dueCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$dueCount due',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dueCount == 0
                ? "You're all caught up! No cards due today."
                : 'You have $dueCount card${dueCount == 1 ? '' : 's'} to review. '
                    'Keep the streak going!',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: dueCount == 0
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReviewSessionScreen(),
                        ),
                      ),
              icon: const Icon(Icons.play_arrow),
              label: Text(dueCount == 0 ? 'No cards due' : 'Start Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                disabledBackgroundColor: Colors.white38,
                disabledForegroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInboxSection(
    BuildContext context,
    EducationProvider provider,
    List<KnowledgeNote> fleetingNotes,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.inbox, color: AppTheme.warningColor, size: 20),
                const SizedBox(width: 8),
                const Text('Inbox', style: AppTextStyles.heading3),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: fleetingNotes.isEmpty
                        ? AppTheme.successColor.withValues(alpha: 0.15)
                        : AppTheme.warningColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    fleetingNotes.isEmpty
                        ? 'Empty'
                        : '${fleetingNotes.length} fleeting',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: fleetingNotes.isEmpty
                          ? AppTheme.successColor
                          : AppTheme.warningColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (fleetingNotes.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Inbox is clear! All fleeting notes have been processed.',
                style: AppTextStyles.bodySmall,
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Review and refine these fleeting notes into permanent knowledge.',
                style: AppTextStyles.caption,
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fleetingNotes.take(5).length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final note = fleetingNotes[index];
                return ListTile(
                  leading: const Icon(
                    Icons.radio_button_unchecked,
                    color: AppTheme.warningColor,
                    size: 20,
                  ),
                  title: Text(
                    note.title,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _formatDate(note.createdAt),
                    style: AppTextStyles.caption,
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NoteDetailScreen(noteId: note.id),
                    ),
                  ),
                );
              },
            ),
            if (fleetingNotes.length > 5)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '+ ${fleetingNotes.length - 5} more…',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyStats(
    BuildContext context,
    EducationProvider provider,
    List<KnowledgeNote> recentNotes,
  ) {
    final streak = provider.currentStreakDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text('This Week', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatTile(
                label: 'Notes added',
                value: '${recentNotes.length}',
                icon: Icons.note_add,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              _StatTile(
                label: 'Streak',
                value: '$streak day${streak == 1 ? '' : 's'}',
                icon: Icons.local_fire_department,
                color: AppTheme.warningColor,
              ),
              const SizedBox(width: 12),
              _StatTile(
                label: 'Cards due',
                value: '${provider.dueCardCount}',
                icon: Icons.style,
                color: AppTheme.secondaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQuickCapture(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _QuickCaptureSheet(),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}

class _QuickCaptureSheet extends StatefulWidget {
  @override
  State<_QuickCaptureSheet> createState() => _QuickCaptureSheetState();
}

class _QuickCaptureSheetState extends State<_QuickCaptureSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text('Quick Capture', style: AppTextStyles.heading3),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Saved as a fleeting note — process it later in your Inbox.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Title *',
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            minLines: 2,
            decoration: const InputDecoration(
              labelText: 'Content (Optional)',
              prefixIcon: Icon(Icons.notes),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Capture'),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    context.read<EducationProvider>().createNote(
          title: title,
          body: _bodyController.text.trim(),
          noteType: NoteType.fleeting,
        );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Captured! Find it in your Inbox.'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
