import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/knowledge_note.dart';
import '../providers/education_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_bar.dart';

class KnowledgeDashboardScreen extends StatelessWidget {
  const KnowledgeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Consumer<EducationProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                _buildStreak(provider),
                _buildGoalsSummary(provider),
                _buildNotesSummary(provider),
                _buildReviewSummary(provider),
                _buildTagCloud(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreak(EducationProvider provider) {
    final streak = provider.currentStreakDays;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: streak > 0 ? 48 : 36,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                streak == 0 ? 'Start your streak!' : '$streak-day streak 🔥',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Add a note or complete an activity each day',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSummary(EducationProvider provider) {
    final total = provider.totalGoals;
    final completed = provider.completedGoalsCount;
    final pct = provider.goalsCompletionPercentage;

    return _SectionCard(
      title: 'Goals',
      icon: Icons.school,
      child: Column(
        children: [
          Row(
            children: [
              _MetricBox(label: 'Total', value: '$total'),
              const SizedBox(width: 12),
              _MetricBox(
                label: 'Completed',
                value: '$completed',
                color: AppTheme.successColor,
              ),
              const SizedBox(width: 12),
              _MetricBox(
                label: 'Active',
                value: '${total - completed}',
                color: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ProgressBar(progress: pct, height: 10),
              ),
              const SizedBox(width: 12),
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSummary(EducationProvider provider) {
    final total = provider.totalNotes;
    final byType = provider.noteCountsByType;

    return _SectionCard(
      title: 'Knowledge Notes',
      icon: Icons.note,
      child: Column(
        children: [
          Row(
            children: [
              _MetricBox(label: 'Total', value: '$total'),
              const SizedBox(width: 12),
              _MetricBox(
                label: 'Fleeting',
                value: '${byType[NoteType.fleeting] ?? 0}',
                color: Colors.grey,
              ),
              const SizedBox(width: 12),
              _MetricBox(
                label: 'Permanent',
                value: '${total - (byType[NoteType.fleeting] ?? 0)}',
                color: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...NoteType.values
              .where((t) => t != NoteType.fleeting)
              .map(
                (type) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _NoteTypeRow(
                    type: type,
                    count: byType[type] ?? 0,
                    total: total,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildReviewSummary(EducationProvider provider) {
    return _SectionCard(
      title: 'Spaced Repetition',
      icon: Icons.style,
      child: Row(
        children: [
          _MetricBox(
            label: 'Total cards',
            value: '${provider.totalCards}',
          ),
          const SizedBox(width: 12),
          _MetricBox(
            label: 'Due today',
            value: '${provider.dueCardCount}',
            color: provider.dueCardCount > 0
                ? AppTheme.warningColor
                : AppTheme.successColor,
          ),
          const SizedBox(width: 12),
          _MetricBox(
            label: 'Resources',
            value: '${provider.totalResources}',
            color: AppTheme.secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTagCloud(EducationProvider provider) {
    final tagCounts = provider.noteTagCounts;
    if (tagCounts.isEmpty) return const SizedBox.shrink();

    final sorted = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTags = sorted.take(20).toList();
    final maxCount = topTags.first.value;

    return _SectionCard(
      title: 'Tag Cloud',
      icon: Icons.tag,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: topTags.map((entry) {
          final weight = entry.value / maxCount;
          final fontSize = 11.0 + (weight * 10);
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor
                  .withValues(alpha: 0.08 + weight * 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryColor
                    .withValues(alpha: 0.2 + weight * 0.3),
              ),
            ),
            child: Text(
              '#${entry.key} (${entry.value})',
              style: TextStyle(
                fontSize: fontSize,
                color: AppTheme.primaryColor,
                fontWeight: weight > 0.5
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 18),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MetricBox({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryColor;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: effectiveColor,
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

class _NoteTypeRow extends StatelessWidget {
  final NoteType type;
  final int count;
  final int total;

  const _NoteTypeRow({
    required this.type,
    required this.count,
    required this.total,
  });

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
    final pct = total == 0 ? 0.0 : (count / total) * 100;
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            type.label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Expanded(
          child: ProgressBar(
            progress: pct,
            height: 8,
            progressColor: _color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _color,
          ),
        ),
      ],
    );
  }
}
