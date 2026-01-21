import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/education_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'goal_detail_screen.dart';
import 'goal_form_dialog.dart';

class GoalsListScreen extends StatelessWidget {
  const GoalsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // TODO: Implement menu actions
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'stats',
                child: Text('View Statistics'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<EducationProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              const SizedBox(height: 8),
              GoalFilterChips(
                selectedFilter: provider.currentFilter,
                onFilterChanged: (filter) => provider.setFilter(filter),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildGoalsList(context, provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGoalDialog(context),
        tooltip: 'Add Goal',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGoalsList(BuildContext context, EducationProvider provider) {
    final goals = provider.goals;

    if (goals.isEmpty) {
      if (provider.currentFilter == GoalFilter.completed) {
        return EmptyState.noCompletedGoals();
      }
      return EmptyState.noGoals(
        onAddGoal: () => _showCreateGoalDialog(context),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Implement refresh from backend
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          final progress = provider.getGoalProgress(goal.id);

          return GoalCard(
            goal: goal,
            progress: progress,
            onTap: () => _navigateToGoalDetail(context, goal.id),
            onCompletionChanged: (value) {
              if (value == true) {
                _showCompleteGoalConfirmation(context, provider, goal.id);
              }
            },
          );
        },
      ),
    );
  }

  void _navigateToGoalDetail(BuildContext context, String goalId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GoalDetailScreen(goalId: goalId),
      ),
    );
  }

  void _showCreateGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const GoalFormDialog(),
    );
  }

  void _showCompleteGoalConfirmation(
    BuildContext context,
    EducationProvider provider,
    String goalId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Goal'),
        content: const Text(
          'Are you sure you want to mark this goal as completed?',
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
                  content: Text('Goal marked as completed!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}
