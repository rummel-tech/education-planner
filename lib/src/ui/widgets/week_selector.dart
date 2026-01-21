import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

class WeekSelector extends StatelessWidget {
  final DateTime weekStartDate;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback? onTodayTap;

  const WeekSelector({
    super.key,
    required this.weekStartDate,
    required this.onPreviousWeek,
    required this.onNextWeek,
    this.onTodayTap,
  });

  @override
  Widget build(BuildContext context) {
    final weekEndDate = weekStartDate.add(const Duration(days: 6));
    final formatter = DateFormat('MMM d');
    final isCurrentWeek = _isCurrentWeek();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPreviousWeek,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous week',
          ),
          GestureDetector(
            onTap: onTodayTap,
            child: Column(
              children: [
                Text(
                  '${formatter.format(weekStartDate)} - ${formatter.format(weekEndDate)}, ${weekStartDate.year}',
                  style: AppTextStyles.heading3,
                ),
                if (!isCurrentWeek && onTodayTap != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Tap to go to current week',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onNextWeek,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next week',
          ),
        ],
      ),
    );
  }

  bool _isCurrentWeek() {
    final now = DateTime.now();
    final currentMonday = _normalizeToMonday(now);
    final selectedMonday = _normalizeToMonday(weekStartDate);
    return currentMonday.isAtSameMomentAs(selectedMonday);
  }

  DateTime _normalizeToMonday(DateTime date) {
    final weekday = date.weekday;
    final daysToSubtract = weekday - 1;
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: daysToSubtract));
  }
}

class WeekProgressCard extends StatelessWidget {
  final int completedActivities;
  final int totalActivities;
  final int completedMinutes;
  final int totalMinutes;
  final double completionPercentage;

  const WeekProgressCard({
    super.key,
    required this.completedActivities,
    required this.totalActivities,
    required this.completedMinutes,
    required this.totalMinutes,
    required this.completionPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Week Progress',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: completionPercentage / 100,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat(
                  '$completedActivities/$totalActivities',
                  'activities',
                  Icons.check_circle_outline,
                ),
                _buildStat(
                  '${_formatMinutes(completedMinutes)}/${_formatMinutes(totalMinutes)}',
                  'time',
                  Icons.timer_outlined,
                ),
                _buildStat(
                  '${completionPercentage.toStringAsFixed(0)}%',
                  'complete',
                  Icons.trending_up,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Color _getProgressColor() {
    if (completionPercentage >= 100) return AppTheme.successColor;
    if (completionPercentage >= 60) return AppTheme.primaryColor;
    if (completionPercentage >= 30) return AppTheme.warningColor;
    return Colors.grey;
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    return '${hours}h${remainingMinutes}m';
  }
}
