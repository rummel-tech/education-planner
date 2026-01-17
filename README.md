# Education Planner

A Dart module for the Artemis system that manages education goals and weekly activity plans.

## Overview

The Education Planner module provides a comprehensive system for:
- Managing education goals with tracking and completion status
- Creating and managing weekly activity plans
- Linking activities to specific education goals
- Tracking progress and completion percentages

## Features

- **Education Goal Management**: Create, update, track, and complete education goals
- **Weekly Planning**: Organize activities into weekly plans with scheduling
- **Activity Tracking**: Schedule activities with durations and link them to goals
- **Progress Monitoring**: Track completion percentages for both goals and weekly plans
- **JSON Serialization**: Full support for JSON serialization/deserialization
- **Type-Safe**: Built with Dart's strong typing system

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  education_planner:
    git:
      url: https://github.com/rummel-tech/education-planner.git
```

Then run:

```bash
dart pub get
```

## Usage

### Creating Education Goals

```dart
import 'package:education_planner/education_planner.dart';

// Create a goal service
final goalService = EducationGoalService();

// Create a new goal
final goal = goalService.createGoal(
  id: 'goal-1',
  title: 'Learn Dart Programming',
  description: 'Master Dart language fundamentals',
  targetDate: DateTime.now().add(Duration(days: 90)),
);

// Mark a goal as completed
goalService.completeGoal('goal-1');

// Get all active goals
final activeGoals = goalService.getActiveGoals();
```

### Creating Weekly Plans

```dart
// Create a plan service
final planService = WeeklyPlanService();

// Create a weekly plan
final plan = planService.createPlan(
  id: 'plan-1',
  title: 'Week 1 Study Plan',
  weekStartDate: DateTime.now(),
);

// Add activities to the plan
final activity = Activity(
  id: 'activity-1',
  title: 'Read Dart documentation',
  description: 'Read chapters 1-3',
  goalId: 'goal-1',
  durationMinutes: 90,
  scheduledTime: DateTime.now().add(Duration(hours: 1)),
);

planService.addActivityToPlan('plan-1', activity);

// Complete an activity
planService.completeActivity('plan-1', 'activity-1');

// Check progress
print('Plan completion: ${plan.completionPercentage}%');
```

### Working with Activities

```dart
// Create an activity
final activity = Activity(
  id: 'activity-1',
  title: 'Study Session',
  description: 'Review data structures',
  goalId: 'goal-1',
  durationMinutes: 60,
  scheduledTime: DateTime(2026, 1, 15, 10, 0),
);

// Get all activities for a specific goal
final goalActivities = planService.getActivitiesForGoal('goal-1');
```

## Core Models

### EducationGoal

Represents an education goal with:
- `id`: Unique identifier
- `title`: Goal title
- `description`: Detailed description
- `createdAt`: Creation timestamp
- `targetDate`: Optional target completion date
- `isCompleted`: Completion status

### Activity

Represents an activity in a weekly plan with:
- `id`: Unique identifier
- `title`: Activity title
- `description`: Optional description
- `goalId`: Optional reference to associated goal
- `durationMinutes`: Planned duration
- `scheduledTime`: When the activity is scheduled
- `isCompleted`: Completion status

### WeeklyPlan

Represents a weekly plan with:
- `id`: Unique identifier
- `title`: Plan title
- `weekStartDate`: Monday of the week
- `activities`: List of scheduled activities
- Methods for tracking completion and progress

## Services

### EducationGoalService

Manages education goals with methods:
- `createGoal()`: Create a new goal
- `getGoal()`: Retrieve a goal by ID
- `getAllGoals()`: Get all goals
- `getActiveGoals()`: Get incomplete goals
- `getCompletedGoals()`: Get completed goals
- `updateGoal()`: Update an existing goal
- `completeGoal()`: Mark a goal as complete
- `deleteGoal()`: Remove a goal

### WeeklyPlanService

Manages weekly plans with methods:
- `createPlan()`: Create a new weekly plan
- `getPlan()`: Retrieve a plan by ID
- `getAllPlans()`: Get all plans
- `addActivityToPlan()`: Add an activity to a plan
- `removeActivityFromPlan()`: Remove an activity
- `completeActivity()`: Mark an activity as complete
- `getActivitiesForGoal()`: Get all activities linked to a goal

## Development

### Running Tests

```bash
dart test
```

### Running the Example

```bash
dart run example/main.dart
```

## License

See LICENSE file for details.