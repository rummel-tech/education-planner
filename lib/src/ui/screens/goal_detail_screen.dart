import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/education_goal.dart';
import '../providers/education_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'goal_form_dialog.dart';

class GoalDetailScreen extends StatelessWidget {
  final String goalId;

  const GoalDetailScreen({
    super.key,
    required this.goalId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<EducationProvider>(
      builder: (context, provider, child) {
        final goal = provider.getGoal(goalId);

        if (goal == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Goal Not Found')),
            body: const Center(
              child: Text('This goal no longer exists.'),
            ),
          );
        }

        final progress = provider.getGoalProgress(goalId);
        final timeSpent = provider.getTotalTimeSpentOnGoal(goalId);
        final activities = provider.getActivitiesForGoal(goalId);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Goal Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditDialog(context, goal),
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
                _buildHeader(context, goal, progress, timeSpent),
                const Divider(height: 1),
                _buildProgressSection(progress),
                const Divider(height: 1),
                _buildActivitiesSection(context, provider, activities),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomSheet: goal.isCompleted
              ? null
              : _buildCompleteButton(context, provider),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    EducationGoal goal,
    double progress,
    int timeSpent,
  ) {
    final formatter = DateFormat('MMM d, yyyy');

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: goal.isCompleted
                      ? AppTheme.successColor.withValues(alpha: 0.2)
                      : AppTheme.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  goal.isCompleted ? Icons.check_circle : Icons.school,
                  color:
                      goal.isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: AppTextStyles.heading2.copyWith(
                        decoration:
                            goal.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (goal.isCompleted)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Completed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            goal.description,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                Icons.timer_outlined,
                '${_formatMinutes(timeSpent)} spent',
              ),
              const SizedBox(width: 12),
              if (goal.targetDate != null)
                _buildInfoChip(
                  Icons.flag,
                  formatter.format(goal.targetDate!),
                  isOverdue: goal.targetDate!.isBefore(DateTime.now()) &&
                      !goal.isCompleted,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {bool isOverdue = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOverdue ? AppTheme.errorColor.withValues(alpha: 0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isOverdue ? AppTheme.errorColor : Colors.grey.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isOverdue ? AppTheme.errorColor : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ProgressBar(
                  progress: progress,
                  height: 12,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection(
    BuildContext context,
    EducationProvider provider,
    List activities,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Linked Activities',
                  style: AppTextStyles.heading3,
                ),
                Text(
                  '${activities.where((a) => a.isCompleted).length}/${activities.length}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          if (activities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: EmptyState(
                icon: Icons.link_off,
                title: 'No linked activities',
                subtitle:
                    'Create activities linked to this goal to track your progress.',
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return CompactActivityRow(
                  activity: activity,
                  onTap: () {
                    // TODO: Navigate to activity in weekly plan
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton(
    BuildContext context,
    EducationProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showCompleteConfirmation(context, provider),
            icon: const Icon(Icons.check),
            label: const Text('Mark Goal as Complete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, EducationGoal goal) {
    showDialog(
      context: context,
      builder: (context) => GoalFormDialog(goal: goal),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    EducationProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text(
          'Are you sure you want to delete this goal? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteGoal(goalId);
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Goal deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCompleteConfirmation(
    BuildContext context,
    EducationProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Goal'),
        content: const Text(
          'Congratulations! Are you sure you want to mark this goal as completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.completeGoal(goalId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Goal completed! Great job!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes == 0) return '0 min';
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }
}
