---
module: education-planner
version: 1.0.0
status: draft
last_updated: 2026-01-20
---

# Education Planner Specification

## Overview

The Education Planner module provides goal-oriented learning management with weekly activity planning. It enables users to set education goals, create weekly study plans, schedule learning activities, and track progress toward educational objectives. The module is implemented as a pure Dart library with in-memory storage, designed for integration into larger applications.

## Authentication

This module uses the shared AWS Amplify authentication system. See [Authentication Architecture](../../../../docs/architecture/AUTHENTICATION.md) for complete details.

### Authentication Modes

| Mode | Description |
|------|-------------|
| Artemis-Integrated | User authenticates via Artemis, gains access to all permitted modules |
| Standalone | User authenticates directly in Education Planner app |

### Module Access

- **Module ID**: `education-planner`
- **Artemis Users**: Full access when `artemis_access: true`
- **Standalone Users**: Access when `education-planner` in `module_access` list

### Login Screen

Uses shared `auth_ui` package with identical UI to all other modules:
- Email/password authentication
- Google Sign-In
- Apple Sign-In
- Email verification flow
- Password reset flow

### API Authentication

All API endpoints require JWT Bearer token from AWS Cognito:
```http
Authorization: Bearer <access_token>
```

## Design System

This module uses the shared Artemis Design System. See [Design System](../../../../docs/architecture/DESIGN_SYSTEM.md) for complete specifications.

### Design Principles

All UI components follow the shared design system to ensure visual consistency across the Artemis ecosystem:

- **Colors**: Rummel Blue primary (`#1E88E5`), Teal secondary (`#26A69A`)
- **Typography**: Material 3 type scale with system fonts
- **Spacing**: Consistent 4dp base unit scale (xs: 4dp, sm: 8dp, md: 16dp, lg: 24dp)
- **Components**: Shared button, card, input, and navigation styles

### Module-Specific Colors

| Element | Color | Token | Usage |
|---------|-------|-------|-------|
| Progress Complete | `#388E3C` | `success` | Completed goals and activities |
| Behind Schedule | `#F57C00` | `warning` | Overdue activities, approaching deadlines |
| Blocked | `#D32F2F` | `error` | Failed activities, critical alerts |
| Goal Badge | `#1E88E5` | `primary500` | Goal association indicators |

### Key Components

| Component | Specification |
|-----------|---------------|
| GoalCard | Card with 12dp radius, primary container badge, progress indicator |
| ActivityCard | Card with checkbox, duration chip, goal badge |
| WeekSelector | Horizontal scroll with date chips, selected state uses primary |
| ProgressBar | Linear progress indicator using semantic colors |
| FilterChips | 8dp radius chips with surfaceVariant background |

### Screen Layouts

All screens follow responsive breakpoints from the shared design system:
- Mobile (< 600dp): Single column, bottom navigation
- Tablet (600-839dp): Flexible columns, navigation rail optional
- Desktop (>= 840dp): Multi-column with navigation rail

## Data Models

### EducationGoal

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | String | Required, unique | Unique identifier for the goal |
| title | String | Required | Title of the education goal |
| description | String | Required | Detailed description of the goal |
| createdAt | DateTime | Required, ISO 8601 | Timestamp when goal was created |
| targetDate | DateTime? | Optional, ISO 8601 | Target completion date |
| isCompleted | bool | Default: false | Whether the goal has been completed |

**Relationships:**
- EducationGoal has many Activities (via goalId reference)

**Indexes (Planned):**
- user_id (for user-scoped queries)
- isCompleted (for filtering active/completed goals)
- targetDate (for deadline-based sorting)

**JSON Serialization:**
```json
{
  "id": "goal-uuid-123",
  "title": "Learn Flutter Development",
  "description": "Complete Flutter course and build 3 apps",
  "createdAt": "2026-01-20T10:00:00.000Z",
  "targetDate": "2026-06-20T00:00:00.000Z",
  "isCompleted": false
}
```

### Activity

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | String | Required, unique | Unique identifier for the activity |
| title | String | Required | Title of the activity |
| description | String? | Optional | Detailed description |
| goalId | String? | Optional, FK to EducationGoal | Associated goal reference |
| durationMinutes | int | Required, > 0 | Planned duration in minutes |
| scheduledTime | DateTime | Required, ISO 8601 | Scheduled date and time |
| isCompleted | bool | Default: false | Whether the activity is completed |

**Relationships:**
- Activity belongs to EducationGoal (optional, via goalId)
- Activity belongs to WeeklyPlan (via plan's activities list)

**Indexes (Planned):**
- goalId (for goal-scoped queries)
- scheduledTime (for chronological sorting)
- isCompleted (for filtering)

**JSON Serialization:**
```json
{
  "id": "activity-uuid-456",
  "title": "Flutter Widgets Chapter",
  "description": "Read chapter 5 and complete exercises",
  "goalId": "goal-uuid-123",
  "durationMinutes": 60,
  "scheduledTime": "2026-01-20T14:00:00.000Z",
  "isCompleted": false
}
```

### WeeklyPlan

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | String | Required, unique | Unique identifier for the plan |
| title | String | Required | Title of the weekly plan |
| weekStartDate | DateTime | Required, normalized to Monday | Start date of the week |
| activities | List\<Activity\> | Default: [] | Activities scheduled for the week |

**Computed Properties:**
- `weekEndDate`: Calculated as weekStartDate + 6 days (Sunday)
- `completedActivities`: Activities where isCompleted == true
- `pendingActivities`: Activities where isCompleted == false
- `totalPlannedMinutes`: Sum of all activity durations
- `completionPercentage`: (completed count / total count) × 100

**Relationships:**
- WeeklyPlan has many Activities (composite relationship)

**Indexes (Planned):**
- user_id (for user-scoped queries)
- weekStartDate (for week lookup)

**JSON Serialization:**
```json
{
  "id": "plan-uuid-789",
  "title": "Week 3 Study Plan",
  "weekStartDate": "2026-01-20T00:00:00.000Z",
  "activities": [...]
}
```

## Use Cases

### UC-001: Create Education Goal

**Actor:** User

**Preconditions:**
- User has access to the education planner

**Flow:**
1. User provides goal title, description, and optional target date
2. System generates unique ID and sets createdAt to current time
3. System creates and stores the goal with isCompleted = false
4. System returns the created goal

**Postconditions:**
- New goal exists in storage
- Goal is retrievable by ID

**Acceptance Criteria:**
- [ ] Goal is created with all required fields
- [ ] ID is unique across all goals
- [ ] createdAt is set to current timestamp
- [ ] Goal can be retrieved immediately after creation

### UC-002: Create Weekly Plan

**Actor:** User

**Preconditions:**
- User has access to the education planner

**Flow:**
1. User provides plan title and week start date
2. System normalizes weekStartDate to Monday of that week
3. System generates unique ID
4. System creates plan with empty activities list
5. System returns the created plan

**Postconditions:**
- New weekly plan exists in storage
- Plan weekStartDate is always a Monday

**Acceptance Criteria:**
- [ ] Plan is created with normalized Monday date
- [ ] Plan has empty activities list initially
- [ ] Plan can be retrieved by ID or by week date

### UC-003: Add Activity to Plan

**Actor:** User

**Preconditions:**
- Weekly plan exists
- Activity details are provided

**Flow:**
1. User provides plan ID and activity details
2. System validates plan exists
3. System creates activity with unique ID
4. System adds activity to plan's activities list
5. System returns success status

**Postconditions:**
- Activity is added to the plan
- Plan's computed properties reflect new activity

**Acceptance Criteria:**
- [ ] Activity is added to correct plan
- [ ] totalPlannedMinutes increases by activity duration
- [ ] Activity can be associated with a goal (optional)

### UC-004: Complete Activity

**Actor:** User

**Preconditions:**
- Activity exists in a plan
- Activity is not already completed

**Flow:**
1. User provides plan ID and activity ID
2. System locates the activity in the plan
3. System sets activity.isCompleted = true
4. System returns success status

**Postconditions:**
- Activity is marked as completed
- Plan's completionPercentage is recalculated

**Acceptance Criteria:**
- [ ] Activity isCompleted changes from false to true
- [ ] completionPercentage reflects the change
- [ ] completedActivities list includes the activity

### UC-005: Track Goal Progress

**Actor:** User

**Preconditions:**
- Goal exists with associated activities

**Flow:**
1. User requests progress for a goal
2. System retrieves all activities linked to the goal (across all plans)
3. System calculates completion metrics
4. System returns progress summary

**Postconditions:**
- Progress data is returned without modifying state

**Acceptance Criteria:**
- [ ] All activities for goal are found across plans
- [ ] Completion percentage is calculated correctly
- [ ] Time spent (completed activities) is summed

### UC-006: View Weekly Schedule

**Actor:** User

**Preconditions:**
- Weekly plan exists for the specified week

**Flow:**
1. User provides a date (any day of the week)
2. System finds plan containing that date
3. System returns plan with all activities
4. Activities are presented in chronological order

**Postconditions:**
- Plan data is returned

**Acceptance Criteria:**
- [ ] Correct plan is found for any day of the week
- [ ] All activities are included
- [ ] Computed properties are accurate

## UI Workflows

### Screen: Goals List (Planned)

**Purpose:** Display all education goals with status indicators

**Entry Points:**
- Main app navigation
- Dashboard quick action

**Components:**
- GoalCard: Displays goal title, description preview, target date, completion status
- FilterChips: Active/Completed filter
- FAB: Add new goal action
- EmptyState: Illustration when no goals exist

**Actions:**
| Action | Trigger | Result |
|--------|---------|--------|
| View Goal | Card tap | Navigate to Goal Detail |
| Add Goal | FAB tap | Open Create Goal dialog |
| Complete Goal | Checkbox tap | Mark goal as completed |
| Filter | Chip tap | Filter goals list |

**Navigation:**
- Card tap → Goal Detail Screen
- FAB → Create Goal Dialog
- Back → Previous Screen

### Screen: Goal Detail (Planned)

**Purpose:** Show goal details and associated activities

**Entry Points:**
- Goals List card tap

**Components:**
- GoalHeader: Title, description, dates, progress bar
- ActivityList: Activities linked to this goal
- ProgressStats: Completion percentage, time spent
- ActionButtons: Edit, Delete, Complete

**Actions:**
| Action | Trigger | Result |
|--------|---------|--------|
| Edit Goal | Edit button | Open Edit Goal dialog |
| Delete Goal | Delete button | Confirm and delete |
| View Activity | Activity tap | Navigate to plan with activity |

**Navigation:**
- Back → Goals List
- Activity tap → Weekly Plan Screen

### Screen: Weekly Plan (Planned)

**Purpose:** Display and manage weekly activities

**Entry Points:**
- Main app navigation
- Goals screen activity link
- Calendar date selection

**Components:**
- WeekSelector: Navigate between weeks
- DayColumn: Activities grouped by day
- ActivityCard: Title, duration, completion checkbox, goal badge
- ProgressBar: Week completion percentage
- FAB: Add activity action

**Actions:**
| Action | Trigger | Result |
|--------|---------|--------|
| Previous Week | Left arrow | Show previous week |
| Next Week | Right arrow | Show next week |
| Complete Activity | Checkbox tap | Mark activity completed |
| Add Activity | FAB tap | Open Add Activity dialog |
| Edit Activity | Card long press | Open Edit Activity dialog |

**Navigation:**
- Week arrows → Load different week
- Goal badge tap → Goal Detail Screen
- Back → Previous Screen

### Screen: Create/Edit Activity (Planned)

**Purpose:** Form for creating or editing activities

**Entry Points:**
- Weekly Plan FAB
- Activity card edit action

**Components:**
- TitleField: Text input for activity title
- DescriptionField: Multiline text input
- GoalSelector: Dropdown to link to goal
- DurationPicker: Minutes input or preset buttons
- DateTimePicker: Schedule date and time
- SaveButton: Submit form

**Actions:**
| Action | Trigger | Result |
|--------|---------|--------|
| Save | Button tap | Validate and save activity |
| Cancel | Back/Cancel | Discard changes |
| Select Goal | Dropdown | Associate with goal |

**Navigation:**
- Save → Return to Weekly Plan
- Cancel → Return to previous screen

## API Specification

### Future REST API Design

The module currently provides a Dart service layer. The following REST API is planned for future implementation.

### GET /education/api/v1/goals

**Description:** Retrieve all education goals for a user

**Authentication:** Required (JWT Bearer)

**Rate Limit:** 60 requests/minute

**Query Parameters:**
| Name | Type | Default | Description |
|------|------|---------|-------------|
| status | string | all | Filter: all, active, completed |
| sort | string | createdAt | Sort field: createdAt, targetDate, title |
| order | string | desc | Sort order: asc, desc |
| limit | int | 20 | Results per page |
| offset | int | 0 | Pagination offset |

**Response 200:**
```json
{
  "data": [
    {
      "id": "goal-uuid-123",
      "title": "Learn Flutter",
      "description": "Complete Flutter course",
      "createdAt": "2026-01-20T10:00:00.000Z",
      "targetDate": "2026-06-20T00:00:00.000Z",
      "isCompleted": false
    }
  ],
  "meta": {
    "total": 5,
    "limit": 20,
    "offset": 0
  }
}
```

**Error Responses:**
| Code | Condition |
|------|-----------|
| 401 | Not authenticated |
| 500 | Server error |

### POST /education/api/v1/goals

**Description:** Create a new education goal

**Authentication:** Required (JWT Bearer)

**Rate Limit:** 30 requests/minute

**Request Body:**
```json
{
  "title": "string - required",
  "description": "string - required",
  "targetDate": "string - optional, ISO 8601"
}
```

**Response 201:**
```json
{
  "data": {
    "id": "goal-uuid-123",
    "title": "Learn Flutter",
    "description": "Complete Flutter course",
    "createdAt": "2026-01-20T10:00:00.000Z",
    "targetDate": "2026-06-20T00:00:00.000Z",
    "isCompleted": false
  }
}
```

**Error Responses:**
| Code | Condition |
|------|-----------|
| 400 | Invalid input (missing required fields) |
| 401 | Not authenticated |

### GET /education/api/v1/goals/{goalId}

**Description:** Retrieve a specific goal by ID

**Authentication:** Required (JWT Bearer)

**Path Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| goalId | string | Yes | Goal unique identifier |

**Response 200:**
```json
{
  "data": {
    "id": "goal-uuid-123",
    "title": "Learn Flutter",
    "description": "Complete Flutter course",
    "createdAt": "2026-01-20T10:00:00.000Z",
    "targetDate": "2026-06-20T00:00:00.000Z",
    "isCompleted": false,
    "activitiesCount": 12,
    "completedActivitiesCount": 5
  }
}
```

**Error Responses:**
| Code | Condition |
|------|-----------|
| 401 | Not authenticated |
| 404 | Goal not found |

### PUT /education/api/v1/goals/{goalId}

**Description:** Update an existing goal

**Authentication:** Required (JWT Bearer)

**Path Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| goalId | string | Yes | Goal unique identifier |

**Request Body:**
```json
{
  "title": "string - optional",
  "description": "string - optional",
  "targetDate": "string - optional",
  "isCompleted": "boolean - optional"
}
```

**Response 200:**
```json
{
  "data": {
    "id": "goal-uuid-123",
    "title": "Updated Title",
    "description": "Updated description",
    "createdAt": "2026-01-20T10:00:00.000Z",
    "targetDate": "2026-06-20T00:00:00.000Z",
    "isCompleted": false
  }
}
```

**Error Responses:**
| Code | Condition |
|------|-----------|
| 400 | Invalid input |
| 401 | Not authenticated |
| 404 | Goal not found |

### DELETE /education/api/v1/goals/{goalId}

**Description:** Delete a goal (soft delete)

**Authentication:** Required (JWT Bearer)

**Path Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| goalId | string | Yes | Goal unique identifier |

**Response 204:** No content

**Error Responses:**
| Code | Condition |
|------|-----------|
| 401 | Not authenticated |
| 404 | Goal not found |

### GET /education/api/v1/plans

**Description:** Retrieve weekly plans

**Authentication:** Required (JWT Bearer)

**Query Parameters:**
| Name | Type | Default | Description |
|------|------|---------|-------------|
| week_start | string | current week | ISO date for week start |
| limit | int | 10 | Results per page |
| offset | int | 0 | Pagination offset |

**Response 200:**
```json
{
  "data": [
    {
      "id": "plan-uuid-789",
      "title": "Week 3 Study Plan",
      "weekStartDate": "2026-01-20T00:00:00.000Z",
      "weekEndDate": "2026-01-26T00:00:00.000Z",
      "activities": [...],
      "totalPlannedMinutes": 420,
      "completionPercentage": 45.5
    }
  ],
  "meta": {
    "total": 12,
    "limit": 10,
    "offset": 0
  }
}
```

### POST /education/api/v1/plans

**Description:** Create a new weekly plan

**Authentication:** Required (JWT Bearer)

**Request Body:**
```json
{
  "title": "string - required",
  "weekStartDate": "string - required, ISO 8601 (will be normalized to Monday)"
}
```

**Response 201:**
```json
{
  "data": {
    "id": "plan-uuid-789",
    "title": "Week 3 Study Plan",
    "weekStartDate": "2026-01-20T00:00:00.000Z",
    "weekEndDate": "2026-01-26T00:00:00.000Z",
    "activities": [],
    "totalPlannedMinutes": 0,
    "completionPercentage": 0
  }
}
```

### POST /education/api/v1/plans/{planId}/activities

**Description:** Add an activity to a weekly plan

**Authentication:** Required (JWT Bearer)

**Path Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| planId | string | Yes | Plan unique identifier |

**Request Body:**
```json
{
  "title": "string - required",
  "description": "string - optional",
  "goalId": "string - optional",
  "durationMinutes": "integer - required, > 0",
  "scheduledTime": "string - required, ISO 8601"
}
```

**Response 201:**
```json
{
  "data": {
    "id": "activity-uuid-456",
    "title": "Flutter Widgets Chapter",
    "description": "Read chapter 5",
    "goalId": "goal-uuid-123",
    "durationMinutes": 60,
    "scheduledTime": "2026-01-20T14:00:00.000Z",
    "isCompleted": false
  }
}
```

### PATCH /education/api/v1/plans/{planId}/activities/{activityId}

**Description:** Update an activity (including marking complete)

**Authentication:** Required (JWT Bearer)

**Path Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| planId | string | Yes | Plan unique identifier |
| activityId | string | Yes | Activity unique identifier |

**Request Body:**
```json
{
  "title": "string - optional",
  "description": "string - optional",
  "durationMinutes": "integer - optional",
  "scheduledTime": "string - optional",
  "isCompleted": "boolean - optional"
}
```

**Response 200:**
```json
{
  "data": {
    "id": "activity-uuid-456",
    "title": "Flutter Widgets Chapter",
    "isCompleted": true
  }
}
```

## Implementation Status

### Data Models

| Model | Status | Notes |
|-------|--------|-------|
| EducationGoal | ✅ Implemented | Full model with JSON serialization |
| Activity | ✅ Implemented | Full model with JSON serialization |
| WeeklyPlan | ✅ Implemented | Includes computed properties |

### Services

| Service | Status | Notes |
|---------|--------|-------|
| EducationGoalService | ✅ Implemented | In-memory CRUD operations |
| WeeklyPlanService | ✅ Implemented | Week normalization, activity management |

### API Endpoints

| Endpoint | Status | Notes |
|----------|--------|-------|
| GET /goals | ⬜ Planned | REST API not yet implemented |
| POST /goals | ⬜ Planned | Currently library-only |
| PUT /goals/{id} | ⬜ Planned | |
| DELETE /goals/{id} | ⬜ Planned | |
| GET /plans | ⬜ Planned | |
| POST /plans | ⬜ Planned | |
| POST /plans/{id}/activities | ⬜ Planned | |
| PATCH /plans/{id}/activities/{id} | ⬜ Planned | |

### UI Screens

| Screen | Status | Notes |
|--------|--------|-------|
| Login | ⬜ Planned | Uses shared auth_ui package |
| Register | ⬜ Planned | Uses shared auth_ui package |
| Goals List | ⬜ Planned | No Flutter UI implemented |
| Goal Detail | ⬜ Planned | |
| Weekly Plan | ⬜ Planned | |
| Create/Edit Activity | ⬜ Planned | |

### Authentication

| Component | Status | Notes |
|-----------|--------|-------|
| AWS Amplify Integration | ⬜ Planned | Shared Cognito User Pool |
| Shared auth_ui Package | ⬜ Planned | Login/register screens |
| Token Validation | ⬜ Planned | Backend JWT verification |
| Module Access Control | ⬜ Planned | Cognito custom attributes |

### Testing

| Component | Status | Notes |
|-----------|--------|-------|
| Model Tests | ✅ Implemented | Full test coverage |
| Service Tests | ✅ Implemented | All service methods tested |
| Integration Tests | ⬜ Planned | |

**Legend:** ✅ Implemented | 🚧 Partial | ⬜ Planned

## Technical Notes

### Dependencies
- Dart SDK: >=3.0.0 <4.0.0
- No external production dependencies (pure Dart)
- Dev: test ^1.24.0, lints ^3.0.0

### Storage
- Current: In-memory Map<String, T> storage
- Planned: PostgreSQL with user_id scoping

### Key Implementation Details
- Week start dates are automatically normalized to Monday
- Activity completion is mutable (not immutable copy)
- JSON serialization uses ISO 8601 for DateTime fields
- Services maintain internal state via private Map collections
