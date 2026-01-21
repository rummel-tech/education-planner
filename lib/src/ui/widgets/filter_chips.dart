import 'package:flutter/material.dart';

import '../providers/education_provider.dart';
import '../theme/app_theme.dart';

class GoalFilterChips extends StatelessWidget {
  final GoalFilter selectedFilter;
  final ValueChanged<GoalFilter> onFilterChanged;

  const GoalFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _FilterChip(
            label: 'Active',
            isSelected: selectedFilter == GoalFilter.active,
            onTap: () => onFilterChanged(GoalFilter.active),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Completed',
            isSelected: selectedFilter == GoalFilter.completed,
            onTap: () => onFilterChanged(GoalFilter.completed),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'All',
            isSelected: selectedFilter == GoalFilter.all,
            onTap: () => onFilterChanged(GoalFilter.all),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppTheme.primaryColor
          : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class DurationChips extends StatelessWidget {
  final int? selectedDuration;
  final ValueChanged<int> onDurationSelected;

  const DurationChips({
    super.key,
    this.selectedDuration,
    required this.onDurationSelected,
  });

  static const List<int> durations = [15, 30, 45, 60, 90, 120];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: durations.map((duration) {
        final isSelected = selectedDuration == duration;
        return Material(
          color: isSelected
              ? AppTheme.primaryColor
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => onDurationSelected(duration),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                _formatDuration(duration),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainingMinutes}m';
  }
}
