import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/activity.dart';
import '../providers/education_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/filter_chips.dart';

class ActivityFormDialog extends StatefulWidget {
  final String planId;
  final Activity? activity;
  final DateTime? initialDate;

  const ActivityFormDialog({
    super.key,
    required this.planId,
    this.activity,
    this.initialDate,
  });

  bool get isEditing => activity != null;

  @override
  State<ActivityFormDialog> createState() => _ActivityFormDialogState();
}

class _ActivityFormDialogState extends State<ActivityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedGoalId;
  int _durationMinutes = 60;
  late DateTime _scheduledDate;
  TimeOfDay _scheduledTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.activity?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.activity?.description ?? '',
    );
    _selectedGoalId = widget.activity?.goalId;
    _durationMinutes = widget.activity?.durationMinutes ?? 60;

    if (widget.activity != null) {
      _scheduledDate = widget.activity!.scheduledTime;
      _scheduledTime = TimeOfDay.fromDateTime(widget.activity!.scheduledTime);
    } else {
      _scheduledDate = widget.initialDate ?? DateTime.now();
      _scheduledTime = const TimeOfDay(hour: 9, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.isEditing ? Icons.edit : Icons.add_circle,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.isEditing ? 'Edit Activity' : 'New Activity',
                        style: AppTextStyles.heading2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'What will you study?',
                      prefixIcon: Icon(Icons.title),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Add details about this activity',
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildGoalSelector(context),
                  const SizedBox(height: 16),
                  _buildDurationSelector(),
                  const SizedBox(height: 16),
                  _buildSchedulePicker(context),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _saveActivity,
                        child: Text(widget.isEditing ? 'Save' : 'Create'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalSelector(BuildContext context) {
    final provider = context.read<EducationProvider>();
    final goals = provider.allGoals.where((g) => !g.isCompleted).toList();

    return DropdownButtonFormField<String?>(
      value: _selectedGoalId,
      decoration: const InputDecoration(
        labelText: 'Link to Goal (Optional)',
        prefixIcon: Icon(Icons.flag),
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('No linked goal'),
        ),
        ...goals.map(
          (goal) => DropdownMenuItem<String?>(
            value: goal.id,
            child: Text(
              goal.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedGoalId = value;
        });
      },
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        DurationChips(
          selectedDuration: _durationMinutes,
          onDurationSelected: (duration) {
            setState(() {
              _durationMinutes = duration;
            });
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Custom: '),
            SizedBox(
              width: 80,
              child: TextFormField(
                initialValue: _durationMinutes.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  suffixText: 'min',
                ),
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null && parsed > 0) {
                    setState(() {
                      _durationMinutes = parsed;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSchedulePicker(BuildContext context) {
    final dateFormatter = DateFormat('EEE, MMM d, yyyy');
    final timeFormatter = DateFormat('h:mm a');
    final scheduledDateTime = DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today, size: 20),
                    isDense: true,
                  ),
                  child: Text(dateFormatter.format(_scheduledDate)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(context),
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.access_time, size: 20),
                    isDense: true,
                  ),
                  child: Text(timeFormatter.format(scheduledDateTime)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _scheduledTime = picked;
      });
    }
  }

  void _saveActivity() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<EducationProvider>();
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final scheduledDateTime = DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );

    if (widget.isEditing) {
      // For editing, we need to remove and re-add (since Activity is not fully mutable)
      final plan = provider.getPlan(widget.planId);
      if (plan != null) {
        // Find and update the activity
        final activityIndex = plan.activities.indexWhere(
          (a) => a.id == widget.activity!.id,
        );
        if (activityIndex != -1) {
          plan.activities[activityIndex] = Activity(
            id: widget.activity!.id,
            title: title,
            description: description.isNotEmpty ? description : null,
            goalId: _selectedGoalId,
            durationMinutes: _durationMinutes,
            scheduledTime: scheduledDateTime,
            isCompleted: widget.activity!.isCompleted,
          );
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity updated')),
      );
    } else {
      provider.addActivity(
        planId: widget.planId,
        title: title,
        description: description.isNotEmpty ? description : null,
        goalId: _selectedGoalId,
        durationMinutes: _durationMinutes,
        scheduledTime: scheduledDateTime,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activity added'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }

    Navigator.of(context).pop();
  }
}
