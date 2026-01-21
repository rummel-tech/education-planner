import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  factory EmptyState.noGoals({VoidCallback? onAddGoal}) {
    return EmptyState(
      icon: Icons.school_outlined,
      title: 'No goals yet',
      subtitle: 'Create your first education goal to start tracking your learning journey.',
      actionLabel: 'Add Goal',
      onAction: onAddGoal,
    );
  }

  factory EmptyState.noActivities({VoidCallback? onAddActivity}) {
    return EmptyState(
      icon: Icons.event_note_outlined,
      title: 'No activities scheduled',
      subtitle: 'Plan your study sessions by adding activities to this week.',
      actionLabel: 'Add Activity',
      onAction: onAddActivity,
    );
  }

  factory EmptyState.noCompletedGoals() {
    return const EmptyState(
      icon: Icons.emoji_events_outlined,
      title: 'No completed goals',
      subtitle: 'Complete your first goal to see it here.',
    );
  }

  factory EmptyState.noLinkedActivities() {
    return const EmptyState(
      icon: Icons.link_off,
      title: 'No linked activities',
      subtitle: 'Create activities linked to this goal to track progress.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
