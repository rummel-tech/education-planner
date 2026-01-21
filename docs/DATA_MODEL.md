# Education Planner - Data Model

## Overview

This document defines the complete data model for the Education Planner module, including both currently implemented entities and planned extensions.

## Entity Relationship Diagram

```
┌─────────────────┐
│      User       │
│─────────────────│
│ id (PK)         │
│ cognitoId       │
│ email           │
│ createdAt       │
└────────┬────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐       1:N      ┌─────────────────┐
│  EducationGoal  │◄───────────────│    Milestone    │
│─────────────────│                │─────────────────│
│ id (PK)         │                │ id (PK)         │
│ userId (FK)     │                │ goalId (FK)     │
│ title           │                │ title           │
│ description     │                │ orderIndex      │
│ category        │                │ isCompleted     │
│ targetDate      │                └─────────────────┘
│ isCompleted     │
│ createdAt       │
└────────┬────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐       N:1      ┌─────────────────┐
│    Activity     │───────────────►│   WeeklyPlan    │
│─────────────────│                │─────────────────│
│ id (PK)         │                │ id (PK)         │
│ goalId (FK)     │                │ userId (FK)     │
│ planId (FK)     │                │ title           │
│ title           │                │ weekStartDate   │
│ description     │                │ createdAt       │
│ durationMinutes │                └─────────────────┘
│ actualMinutes   │
│ scheduledTime   │
│ isCompleted     │
│ completedAt     │
└─────────────────┘

┌─────────────────┐       1:N      ┌─────────────────┐
│  LearningPath   │◄───────────────│ LearningPathItem│
│─────────────────│                │─────────────────│
│ id (PK)         │                │ id (PK)         │
│ userId (FK)     │                │ pathId (FK)     │
│ title           │                │ resourceId (FK) │
│ description     │                │ orderIndex      │
│ isPublic        │                │ isCompleted     │
│ createdAt       │                └────────┬────────┘
└─────────────────┘                         │
                                            │ N:1
                                            ▼
┌─────────────────┐       N:M      ┌─────────────────┐
│    Resource     │◄───────────────│ ResourceGoal    │
│─────────────────│  (junction)    │─────────────────│
│ id (PK)         │                │ resourceId (FK) │
│ userId (FK)     │                │ goalId (FK)     │
│ title           │───────────────►└─────────────────┘
│ url             │
│ type            │
│ category        │
│ notes           │
│ rating          │
│ createdAt       │
└─────────────────┘
```

---

## Core Entities

### User

Represents an authenticated user of the system. Linked to AWS Cognito for authentication.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Internal unique identifier |
| cognitoId | String | UNIQUE, NOT NULL | AWS Cognito sub (subject) ID |
| email | String | UNIQUE, NOT NULL | User's email address |
| displayName | String | NULL | Optional display name |
| createdAt | DateTime | NOT NULL, DEFAULT NOW | Account creation timestamp |
| updatedAt | DateTime | NOT NULL | Last update timestamp |

**Indexes:**
- `idx_user_cognito_id` on `cognitoId` (unique)
- `idx_user_email` on `email` (unique)

---

### EducationGoal

Represents a learning objective the user wants to achieve.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Unique identifier |
| userId | UUID | FK → User, NOT NULL | Owner of the goal |
| title | String(255) | NOT NULL | Goal title |
| description | Text | NOT NULL | Detailed description |
| category | Enum | NOT NULL, DEFAULT 'personal' | Goal category |
| targetDate | DateTime | NULL | Target completion date |
| isCompleted | Boolean | NOT NULL, DEFAULT false | Completion status |
| completedAt | DateTime | NULL | When goal was completed |
| createdAt | DateTime | NOT NULL, DEFAULT NOW | Creation timestamp |
| updatedAt | DateTime | NOT NULL | Last update timestamp |
| deletedAt | DateTime | NULL | Soft delete timestamp |

**Category Enum Values:**
- `professional` - Career/work-related learning
- `personal` - Personal development
- `hobby` - Recreational learning
- `academic` - Formal education

**Indexes:**
- `idx_goal_user_id` on `userId`
- `idx_goal_category` on `category`
- `idx_goal_completed` on `isCompleted`
- `idx_goal_target_date` on `targetDate`
- `idx_goal_deleted` on `deletedAt` (partial: WHERE deletedAt IS NULL)

**Computed Properties:**
- `progressPercentage`: Calculated from completed milestones or linked activities
- `daysRemaining`: Calculated from targetDate - current date

**JSON Example:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "userId": "660e8400-e29b-41d4-a716-446655440001",
  "title": "Learn Flutter Development",
  "description": "Complete Flutter course and build 3 production apps",
  "category": "professional",
  "targetDate": "2026-06-20T00:00:00.000Z",
  "isCompleted": false,
  "completedAt": null,
  "createdAt": "2026-01-20T10:00:00.000Z",
  "updatedAt": "2026-01-20T10:00:00.000Z"
}
```

---

### Milestone

Represents a sub-goal or checkpoint within an education goal.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Unique identifier |
| goalId | UUID | FK → EducationGoal, NOT NULL | Parent goal |
| title | String(255) | NOT NULL | Milestone title |
| description | Text | NULL | Optional description |
| orderIndex | Integer | NOT NULL, DEFAULT 0 | Display order within goal |
| isCompleted | Boolean | NOT NULL, DEFAULT false | Completion status |
| completedAt | DateTime | NULL | When milestone was completed |
| createdAt | DateTime | NOT NULL, DEFAULT NOW | Creation timestamp |

**Indexes:**
- `idx_milestone_goal_id` on `goalId`
- `idx_milestone_order` on `(goalId, orderIndex)`

**JSON Example:**
```json
{
  "id": "770e8400-e29b-41d4-a716-446655440002",
  "goalId": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Complete Dart fundamentals",
  "description": "Finish Dart language course chapters 1-10",
  "orderIndex": 0,
  "isCompleted": true,
  "completedAt": "2026-01-15T14:30:00.000Z"
}
```

---

### WeeklyPlan

Represents a weekly study schedule containing activities.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Unique identifier |
| userId | UUID | FK → User, NOT NULL | Owner of the plan |
| title | String(255) | NOT NULL | Plan title |
| weekStartDate | Date | NOT NULL | Monday of the week (normalized) |
| createdAt | DateTime | NOT NULL, DEFAULT NOW | Creation timestamp |
| updatedAt | DateTime | NOT NULL | Last update timestamp |

**Constraints:**
- `UNIQUE(userId, weekStartDate)` - One plan per user per week
- `weekStartDate` must be a Monday (enforced at application level)

**Indexes:**
- `idx_plan_user_id` on `userId`
- `idx_plan_week_start` on `weekStartDate`
- `idx_plan_user_week` on `(userId, weekStartDate)` (unique)

**Computed Properties:**
- `weekEndDate`: weekStartDate + 6 days (Sunday)
- `totalPlannedMinutes`: Sum of all activity durations
- `totalCompletedMinutes`: Sum of completed activity durations
- `completionPercentage`: (completed activities / total activities) × 100
- `completedActivities`: List where isCompleted = true
- `pendingActivities`: List where isCompleted = false

**JSON Example:**
```json
{
  "id": "880e8400-e29b-41d4-a716-446655440003",
  "userId": "660e8400-e29b-41d4-a716-446655440001",
  "title": "Week 3 Study Plan",
  "weekStartDate": "2026-01-20",
  "weekEndDate": "2026-01-26",
  "totalPlannedMinutes": 420,
  "completionPercentage": 45.5,
  "createdAt": "2026-01-19T18:00:00.000Z"
}
```

---

### Activity

Represents a scheduled learning activity within a weekly plan.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Unique identifier |
| planId | UUID | FK → WeeklyPlan, NOT NULL | Parent weekly plan |
| goalId | UUID | FK → EducationGoal, NULL | Associated goal (optional) |
| title | String(255) | NOT NULL | Activity title |
| description | Text | NULL | Optional description |
| durationMinutes | Integer | NOT NULL, > 0 | Planned duration in minutes |
| actualMinutes | Integer | NULL, >= 0 | Actual time spent (logged after completion) |
| scheduledTime | DateTime | NOT NULL | Scheduled date and time |
| isCompleted | Boolean | NOT NULL, DEFAULT false | Completion status |
| completedAt | DateTime | NULL | When activity was completed |
| createdAt | DateTime | NOT NULL, DEFAULT NOW | Creation timestamp |
| updatedAt | DateTime | NOT NULL | Last update timestamp |

**Indexes:**
- `idx_activity_plan_id` on `planId`
- `idx_activity_goal_id` on `goalId`
- `idx_activity_scheduled` on `scheduledTime`
- `idx_activity_completed` on `isCompleted`

**JSON Example:**
```json
{
  "id": "990e8400-e29b-41d4-a716-446655440004",
  "planId": "880e8400-e29b-41d4-a716-446655440003",
  "goalId": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Flutter Widgets Chapter",
  "description": "Read chapter 5 and complete exercises",
  "durationMinutes": 60,
  "actualMinutes": 75,
  "scheduledTime": "2026-01-20T14:00:00.000Z",
  "isCompleted": true,
  "completedAt": "2026-01-20T15:15:00.000Z"
}
```

---

## Extended Entities (Planned)

### LearningPath

Represents a structured sequence of resources for achieving a learning objective.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Unique identifier |
| userId | UUID | FK → User, NOT NULL | Creator/owner |
| title | String(255) | NOT NULL | Path title |
| description | Text | NULL | Path description |
| estimatedHours | Integer | NULL | Estimated total hours |
| difficulty | Enum | NOT NULL, DEFAULT 'intermediate' | Difficulty level |
| isPublic | Boolean | NOT NULL, DEFAULT false | Publicly shareable |
| clonedFromId | UUID | FK → LearningPath, NULL | Source if cloned |
| createdAt | DateTime | NOT NULL, DEFAULT NOW | Creation timestamp |
| updatedAt | DateTime | NOT NULL | Last update timestamp |

**Difficulty Enum Values:**
- `beginner`
- `intermediate`
- `advanced`
- `expert`

**Indexes:**
- `idx_path_user_id` on `userId`
- `idx_path_public` on `isPublic`
- `idx_path_cloned` on `clonedFromId`

---

### LearningPathItem

Represents an item (resource) within a learning path with ordering and prerequisites.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Unique identifier |
| pathId | UUID | FK → LearningPath, NOT NULL | Parent learning path |
| resourceId | UUID | FK → Resource, NULL | Linked resource (optional) |
| title | String(255) | NOT NULL | Item title (override or standalone) |
| description | Text | NULL | Item description |
| orderIndex | Integer | NOT NULL | Position in path sequence |
| estimatedMinutes | Integer | NULL | Estimated time for this item |
| isCompleted | Boolean | NOT NULL, DEFAULT false | Completion status |
| completedAt | DateTime | NULL | Completion timestamp |

**Indexes:**
- `idx_pathitem_path_id` on `pathId`
- `idx_pathitem_order` on `(pathId, orderIndex)`
- `idx_pathitem_resource` on `resourceId`

---

### LearningPathPrerequisite

Junction table defining prerequisite relationships between path items.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| itemId | UUID | FK → LearningPathItem, NOT NULL | The item that has prerequisites |
| prerequisiteId | UUID | FK → LearningPathItem, NOT NULL | The required prerequisite item |

**Constraints:**
- `PK(itemId, prerequisiteId)`
- Both items must belong to the same path (enforced at application level)

---

### Resource

Represents a learning resource (course, article, video, book, etc.).

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Unique identifier |
| userId | UUID | FK → User, NOT NULL | Owner of the resource |
| title | String(255) | NOT NULL | Resource title |
| url | String(2048) | NULL | External URL |
| type | Enum | NOT NULL | Resource type |
| category | String(100) | NULL | Subject category |
| notes | Text | NULL | Personal notes |
| rating | Integer | NULL, 1-5 | Personal rating |
| isCompleted | Boolean | NOT NULL, DEFAULT false | Completion status |
| completedAt | DateTime | NULL | Completion timestamp |
| createdAt | DateTime | NOT NULL, DEFAULT NOW | Creation timestamp |
| updatedAt | DateTime | NOT NULL | Last update timestamp |

**Type Enum Values:**
- `course` - Online course
- `video` - Video content
- `article` - Article or blog post
- `book` - Book or ebook
- `tutorial` - Tutorial or guide
- `documentation` - Technical documentation
- `podcast` - Audio content
- `other` - Other resource type

**Indexes:**
- `idx_resource_user_id` on `userId`
- `idx_resource_type` on `type`
- `idx_resource_category` on `category`
- `idx_resource_completed` on `isCompleted`

**JSON Example:**
```json
{
  "id": "aa0e8400-e29b-41d4-a716-446655440005",
  "userId": "660e8400-e29b-41d4-a716-446655440001",
  "title": "Flutter & Dart - The Complete Guide",
  "url": "https://www.udemy.com/course/learn-flutter-dart",
  "type": "course",
  "category": "Mobile Development",
  "notes": "Excellent course, very comprehensive",
  "rating": 5,
  "isCompleted": false
}
```

---

### ResourceGoal

Junction table linking resources to goals (many-to-many).

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| resourceId | UUID | FK → Resource, NOT NULL | Resource reference |
| goalId | UUID | FK → EducationGoal, NOT NULL | Goal reference |
| createdAt | DateTime | NOT NULL, DEFAULT NOW | Link creation timestamp |

**Constraints:**
- `PK(resourceId, goalId)`

---

## Analytics Entities (Planned)

### StudySession

Tracks actual study time for analytics and focus integration.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Unique identifier |
| userId | UUID | FK → User, NOT NULL | Session owner |
| activityId | UUID | FK → Activity, NULL | Associated activity |
| goalId | UUID | FK → EducationGoal, NULL | Associated goal |
| startTime | DateTime | NOT NULL | Session start time |
| endTime | DateTime | NULL | Session end time |
| durationMinutes | Integer | NULL | Calculated duration |
| focusScore | Integer | NULL, 0-100 | Focus Training integration score |
| notes | Text | NULL | Session notes |

**Indexes:**
- `idx_session_user_id` on `userId`
- `idx_session_start` on `startTime`
- `idx_session_activity` on `activityId`
- `idx_session_goal` on `goalId`

---

### StudyStreak

Tracks consecutive days of study activity.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Unique identifier |
| userId | UUID | FK → User, NOT NULL | User reference |
| currentStreak | Integer | NOT NULL, DEFAULT 0 | Current consecutive days |
| longestStreak | Integer | NOT NULL, DEFAULT 0 | All-time longest streak |
| lastActivityDate | Date | NULL | Last day with activity |
| updatedAt | DateTime | NOT NULL | Last update timestamp |

**Constraints:**
- `UNIQUE(userId)` - One streak record per user

---

## Database Schema (PostgreSQL)

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cognito_id VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    display_name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Education Goals table
CREATE TABLE education_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL DEFAULT 'personal',
    target_date TIMESTAMP WITH TIME ZONE,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT chk_category CHECK (category IN ('professional', 'personal', 'hobby', 'academic'))
);

CREATE INDEX idx_goal_user_id ON education_goals(user_id);
CREATE INDEX idx_goal_category ON education_goals(category);
CREATE INDEX idx_goal_completed ON education_goals(is_completed);
CREATE INDEX idx_goal_target_date ON education_goals(target_date);
CREATE INDEX idx_goal_active ON education_goals(user_id) WHERE deleted_at IS NULL;

-- Milestones table
CREATE TABLE milestones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goal_id UUID NOT NULL REFERENCES education_goals(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    order_index INTEGER NOT NULL DEFAULT 0,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_milestone_goal_id ON milestones(goal_id);
CREATE INDEX idx_milestone_order ON milestones(goal_id, order_index);

-- Weekly Plans table
CREATE TABLE weekly_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    week_start_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_user_week UNIQUE (user_id, week_start_date)
);

CREATE INDEX idx_plan_user_id ON weekly_plans(user_id);
CREATE INDEX idx_plan_week_start ON weekly_plans(week_start_date);

-- Activities table
CREATE TABLE activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plan_id UUID NOT NULL REFERENCES weekly_plans(id) ON DELETE CASCADE,
    goal_id UUID REFERENCES education_goals(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    actual_minutes INTEGER CHECK (actual_minutes >= 0),
    scheduled_time TIMESTAMP WITH TIME ZONE NOT NULL,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_activity_plan_id ON activities(plan_id);
CREATE INDEX idx_activity_goal_id ON activities(goal_id);
CREATE INDEX idx_activity_scheduled ON activities(scheduled_time);
CREATE INDEX idx_activity_completed ON activities(is_completed);

-- Resources table
CREATE TABLE resources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    url VARCHAR(2048),
    type VARCHAR(50) NOT NULL,
    category VARCHAR(100),
    notes TEXT,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_resource_type CHECK (type IN ('course', 'video', 'article', 'book', 'tutorial', 'documentation', 'podcast', 'other'))
);

CREATE INDEX idx_resource_user_id ON resources(user_id);
CREATE INDEX idx_resource_type ON resources(type);
CREATE INDEX idx_resource_category ON resources(category);

-- Resource-Goal junction table
CREATE TABLE resource_goals (
    resource_id UUID NOT NULL REFERENCES resources(id) ON DELETE CASCADE,
    goal_id UUID NOT NULL REFERENCES education_goals(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    PRIMARY KEY (resource_id, goal_id)
);

-- Learning Paths table
CREATE TABLE learning_paths (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    estimated_hours INTEGER,
    difficulty VARCHAR(50) NOT NULL DEFAULT 'intermediate',
    is_public BOOLEAN NOT NULL DEFAULT FALSE,
    cloned_from_id UUID REFERENCES learning_paths(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_difficulty CHECK (difficulty IN ('beginner', 'intermediate', 'advanced', 'expert'))
);

CREATE INDEX idx_path_user_id ON learning_paths(user_id);
CREATE INDEX idx_path_public ON learning_paths(is_public);

-- Learning Path Items table
CREATE TABLE learning_path_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    path_id UUID NOT NULL REFERENCES learning_paths(id) ON DELETE CASCADE,
    resource_id UUID REFERENCES resources(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    order_index INTEGER NOT NULL,
    estimated_minutes INTEGER,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_pathitem_path_id ON learning_path_items(path_id);
CREATE INDEX idx_pathitem_order ON learning_path_items(path_id, order_index);

-- Learning Path Prerequisites table
CREATE TABLE learning_path_prerequisites (
    item_id UUID NOT NULL REFERENCES learning_path_items(id) ON DELETE CASCADE,
    prerequisite_id UUID NOT NULL REFERENCES learning_path_items(id) ON DELETE CASCADE,

    PRIMARY KEY (item_id, prerequisite_id),
    CONSTRAINT chk_no_self_prereq CHECK (item_id != prerequisite_id)
);

-- Study Sessions table (for analytics)
CREATE TABLE study_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_id UUID REFERENCES activities(id) ON DELETE SET NULL,
    goal_id UUID REFERENCES education_goals(id) ON DELETE SET NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER,
    focus_score INTEGER CHECK (focus_score >= 0 AND focus_score <= 100),
    notes TEXT
);

CREATE INDEX idx_session_user_id ON study_sessions(user_id);
CREATE INDEX idx_session_start ON study_sessions(start_time);
CREATE INDEX idx_session_activity ON study_sessions(activity_id);

-- Study Streaks table
CREATE TABLE study_streaks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    current_streak INTEGER NOT NULL DEFAULT 0,
    longest_streak INTEGER NOT NULL DEFAULT 0,
    last_activity_date DATE,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Trigger to update updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_goals_updated_at BEFORE UPDATE ON education_goals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_plans_updated_at BEFORE UPDATE ON weekly_plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_activities_updated_at BEFORE UPDATE ON activities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_resources_updated_at BEFORE UPDATE ON resources
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_paths_updated_at BEFORE UPDATE ON learning_paths
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_streaks_updated_at BEFORE UPDATE ON study_streaks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

---

## Implementation Status

| Entity | Dart Model | Database | API |
|--------|------------|----------|-----|
| User | Planned | Planned | Planned |
| EducationGoal | ✅ Implemented | Planned | Planned |
| Milestone | Planned | Planned | Planned |
| WeeklyPlan | ✅ Implemented | Planned | Planned |
| Activity | ✅ Implemented | Planned | Planned |
| LearningPath | Planned | Planned | Planned |
| LearningPathItem | Planned | Planned | Planned |
| Resource | Planned | Planned | Planned |
| ResourceGoal | Planned | Planned | Planned |
| StudySession | Planned | Planned | Planned |
| StudyStreak | Planned | Planned | Planned |

---

## Migration Path

### Phase 1: Current State
- In-memory Map storage
- Three core models: EducationGoal, Activity, WeeklyPlan

### Phase 2: Database Persistence
- Add PostgreSQL database
- Add User entity with Cognito integration
- Add userId to existing entities
- Add Milestone entity

### Phase 3: Extended Features
- Add Resource and ResourceGoal entities
- Add LearningPath and LearningPathItem entities
- Add LearningPathPrerequisite for dependencies

### Phase 4: Analytics
- Add StudySession for time tracking
- Add StudyStreak for gamification
- Focus Training integration

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-20 | Initial data model specification |
