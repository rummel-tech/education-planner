import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/activity.dart';
import '../../models/education_goal.dart';
import '../theme/app_theme.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final EducationGoal? linkedGoal;
  final ValueChanged<bool?>? onCompletionChanged;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onGoalTap;

  const ActivityCard({
    super.key,
    required this.activity,
    this.linkedGoal,
    this.onCompletionChanged,
    this.onTap,
    this.onLongPress,
    this.onGoalTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: activity.isCompleted,
                onChanged: onCompletionChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: activity.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: activity.isCompleted ? Colors.grey : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildTimeChip(),
                        const SizedBox(width: 8),
                        _buildDurationChip(),
                      ],
                    ),
                    if (linkedGoal != null) ...[
                      const SizedBox(height: 8),
                      _buildGoalBadge(context),
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

  Widget _buildTimeChip() {
    final formatter = DateFormat('h:mm a');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 12,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            formatter.format(activity.scheduledTime),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 12,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDuration(activity.durationMinutes),
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalBadge(BuildContext context) {
    return GestureDetector(
      onTap: onGoalTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.flag,
              size: 14,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                linkedGoal!.title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainingMinutes}m';
  }
}

class CompactActivityRow extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onTap;

  const CompactActivityRow({
    super.key,
    required this.activity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('EEE, MMM d');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Icon(
              activity.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: activity.isCompleted
                  ? AppTheme.successColor
                  : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: TextStyle(
                      fontSize: 14,
                      decoration: activity.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: activity.isCompleted ? Colors.grey : null,
                    ),
                  ),
                  Text(
                    '${formatter.format(activity.scheduledTime)} - ${activity.durationMinutes} min',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
