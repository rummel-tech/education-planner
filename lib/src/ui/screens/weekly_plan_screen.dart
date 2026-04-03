import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/activity.dart';
import '../../models/weekly_plan.dart';
import '../providers/education_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'activity_form_dialog.dart';
import 'goal_detail_screen.dart';
import 'search_screen.dart';

class WeeklyPlanScreen extends StatelessWidget {
  const WeeklyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              context.read<EducationProvider>().navigateToCurrentWeek();
            },
            tooltip: 'Go to current week',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<EducationProvider>(
        builder: (context, provider, child) {
          final plan = provider.currentWeekPlan;

          return Column(
            children: [
              WeekSelector(
                weekStartDate: _normalizeToMonday(provider.selectedWeek),
                onPreviousWeek: provider.navigateToPreviousWeek,
                onNextWeek: provider.navigateToNextWeek,
                onTodayTap: provider.navigateToCurrentWeek,
              ),
              Expanded(
                child: plan == null
                    ? _buildEmptyWeek(context, provider)
                    : _buildWeekContent(context, provider, plan),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddActivityDialog(context),
        tooltip: 'Add Activity',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyWeek(BuildContext context, EducationProvider provider) {
    return EmptyState.noActivities(
      onAddActivity: () => _showAddActivityDialog(context),
    );
  }

  Widget _buildWeekContent(
    BuildContext context,
    EducationProvider provider,
    WeeklyPlan plan,
  ) {
    final activitiesByDay = _groupActivitiesByDay(plan);
    final completedMinutes = plan.completedActivities
        .fold<int>(0, (sum, a) => sum + a.durationMinutes);

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Implement refresh from backend
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          WeekProgressCard(
            completedActivities: plan.completedActivities.length,
            totalActivities: plan.activities.length,
            completedMinutes: completedMinutes,
            totalMinutes: plan.totalPlannedMinutes,
            completionPercentage: plan.completionPercentage,
          ),
          ...List.generate(7, (index) {
            final day = plan.weekStartDate.add(Duration(days: index));
            final dayActivities = activitiesByDay[index] ?? [];
            return _buildDaySection(context, provider, plan, day, dayActivities);
          }),
        ],
      ),
    );
  }

  Map<int, List<Activity>> _groupActivitiesByDay(WeeklyPlan plan) {
    final Map<int, List<Activity>> grouped = {};

    for (final activity in plan.activities) {
      final dayIndex = activity.scheduledTime
          .difference(plan.weekStartDate)
          .inDays
          .clamp(0, 6);
      grouped.putIfAbsent(dayIndex, () => []);
      grouped[dayIndex]!.add(activity);
    }

    // Sort activities by scheduled time within each day
    for (final activities in grouped.values) {
      activities.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    }

    return grouped;
  }

  Widget _buildDaySection(
    BuildContext context,
    EducationProvider provider,
    WeeklyPlan plan,
    DateTime day,
    List<Activity> activities,
  ) {
    final dayFormatter = DateFormat('EEE');
    final dateFormatter = DateFormat('d');
    final isToday = _isToday(day);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isToday
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isToday ? AppTheme.primaryColor : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayFormatter.format(day).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        dateFormatter.format(day),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE').format(day),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isToday ? AppTheme.primaryColor : null,
                        ),
                      ),
                      if (activities.isNotEmpty)
                        Text(
                          '${activities.length} ${activities.length == 1 ? 'activity' : 'activities'}',
                          style: AppTextStyles.caption,
                        ),
                    ],
                  ),
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'TODAY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (activities.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No activities scheduled',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...activities.map(
              (activity) => _buildActivityItem(context, provider, plan, activity),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    EducationProvider provider,
    WeeklyPlan plan,
    Activity activity,
  ) {
    final linkedGoal =
        activity.goalId != null ? provider.getGoal(activity.goalId!) : null;

    return ActivityCard(
      activity: activity,
      linkedGoal: linkedGoal,
      onCompletionChanged: (value) {
        provider.toggleActivityCompletion(plan.id, activity.id);
      },
      onTap: () => _showEditActivityDialog(context, plan.id, activity),
      onLongPress: () => _showActivityOptions(context, provider, plan, activity),
      onGoalTap: linkedGoal != null
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GoalDetailScreen(goalId: linkedGoal.id),
                ),
              )
          : null,
    );
  }

  void _showAddActivityDialog(BuildContext context) {
    final provider = context.read<EducationProvider>();
    final plan = provider.getOrCreatePlanForWeek(provider.selectedWeek);

    showDialog(
      context: context,
      builder: (context) => ActivityFormDialog(
        planId: plan.id,
        initialDate: provider.selectedWeek,
      ),
    );
  }

  void _showEditActivityDialog(
    BuildContext context,
    String planId,
    Activity activity,
  ) {
    showDialog(
      context: context,
      builder: (context) => ActivityFormDialog(
        planId: planId,
        activity: activity,
      ),
    );
  }

  void _showActivityOptions(
    BuildContext context,
    EducationProvider provider,
    WeeklyPlan plan,
    Activity activity,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Activity'),
              onTap: () {
                Navigator.of(context).pop();
                _showEditActivityDialog(context, plan.id, activity);
              },
            ),
            ListTile(
              leading: Icon(
                activity.isCompleted
                    ? Icons.undo
                    : Icons.check_circle_outline,
              ),
              title: Text(
                activity.isCompleted
                    ? 'Mark as Incomplete'
                    : 'Mark as Complete',
              ),
              onTap: () {
                provider.toggleActivityCompletion(plan.id, activity.id);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.errorColor),
              title: const Text(
                'Delete Activity',
                style: TextStyle(color: AppTheme.errorColor),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteActivityConfirmation(
                  context,
                  provider,
                  plan.id,
                  activity.id,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteActivityConfirmation(
    BuildContext context,
    EducationProvider provider,
    String planId,
    String activityId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text(
          'Are you sure you want to delete this activity?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.removeActivity(planId, activityId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Activity deleted')),
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

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;
  }

  DateTime _normalizeToMonday(DateTime date) {
    final weekday = date.weekday;
    final daysToSubtract = weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysToSubtract));
  }
}
