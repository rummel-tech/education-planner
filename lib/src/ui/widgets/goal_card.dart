import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/education_goal.dart';
import '../theme/app_theme.dart';
import 'progress_bar.dart';

class GoalCard extends StatelessWidget {
  final EducationGoal goal;
  final double progress;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onCompletionChanged;

  const GoalCard({
    super.key,
    required this.goal,
    this.progress = 0.0,
    this.onTap,
    this.onCompletionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  _buildCategoryIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: AppTextStyles.heading3.copyWith(
                            decoration: goal.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          goal.description,
                          style: AppTextStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (onCompletionChanged != null)
                    Checkbox(
                      value: goal.isCompleted,
                      onChanged: onCompletionChanged,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ProgressBar(
                progress: progress,
                height: 8,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${progress.toStringAsFixed(0)}% complete',
                    style: AppTextStyles.caption,
                  ),
                  if (goal.targetDate != null) _buildTargetDate(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getCategoryColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getCategoryIcon(),
        color: _getCategoryColor(),
        size: 24,
      ),
    );
  }

  IconData _getCategoryIcon() {
    if (goal.isCompleted) return Icons.check_circle;
    return Icons.school;
  }

  Color _getCategoryColor() {
    if (goal.isCompleted) return AppTheme.successColor;
    if (goal.targetDate != null && goal.targetDate!.isBefore(DateTime.now())) {
      return AppTheme.errorColor;
    }
    return AppTheme.primaryColor;
  }

  Widget _buildTargetDate() {
    final formatter = DateFormat('MMM d, yyyy');
    final isOverdue = goal.targetDate!.isBefore(DateTime.now()) && !goal.isCompleted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.flag,
          size: 14,
          color: isOverdue ? AppTheme.errorColor : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          formatter.format(goal.targetDate!),
          style: AppTextStyles.caption.copyWith(
            color: isOverdue ? AppTheme.errorColor : null,
          ),
        ),
      ],
    );
  }
}
