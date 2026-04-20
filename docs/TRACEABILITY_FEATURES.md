# Education Planner — Feature Traceability Matrix

Maps each user-facing feature from OBJECTIVES.md through specification, tests, implementation, and release verification.

---

## Traceability Chain

```
OBJECTIVES.md (product description)
    → docs/SPECIFICATION.md / docs/ARCHITECTURE.md (specification)
    → docs/WORKFLOWS.md (primary user journeys and screen map)
        → test/models/ — model unit tests
        → test/services/ — service unit tests
        → test/widget_test.dart — app smoke test
        → integration_test/app_test.dart — end-to-end workflow tests
            → Source implementation
                → docs/DEPLOYMENT.md smoke test (release gate)
```

---

## Development Status Note

Education Planner is in early development. The core models and services are implemented and tested. The Flutter UI exists but has no screen-level tests yet. Backend API is planned.

---

## FR-1 · Goals

| ID | Feature | Product Spec | Tests | Implementation | Release Gate |
|----|---------|-------------|-------|----------------|--------------|
| FR-1.1 | Create education goals with target dates | OBJECTIVES.md FR-1.1 | `test/models/education_goal_test` — "creates a goal with required fields", "creates a goal with optional target date", "toJson converts goal to JSON", "fromJson creates goal from JSON" · `test/services/education_goal_service_test` — "createGoal creates and stores a new goal" | `lib/src/models/education_goal.dart` · `lib/src/services/education_goal_service.dart` · `lib/src/ui/screens/goal_form_dialog.dart` | — |
| FR-1.2 | Break goals into milestones | OBJECTIVES.md FR-1.2 | None — gap | `lib/src/models/education_goal.dart` | — |
| FR-1.3 | Mark goals as complete | OBJECTIVES.md FR-1.3 | `test/services/education_goal_service_test` — "getActiveGoals returns only incomplete goals" | `lib/src/services/education_goal_service.dart` · `lib/src/ui/screens/goal_detail_screen.dart` | — |
| FR-1.4 | Track goal progress percentage | OBJECTIVES.md FR-1.4 | None — gap | `lib/src/models/education_goal.dart` · `lib/src/ui/widgets/progress_bar.dart` | — |
| FR-1.5 | Goal categories (professional, personal, hobby) | OBJECTIVES.md FR-1.5 | None — gap | `lib/src/models/education_goal.dart` · `lib/src/ui/widgets/filter_chips.dart` | — |
| FR-1.6 | Retrieve goal by ID; list all goals; list active goals | OBJECTIVES.md FR-1.1 | `test/services/education_goal_service_test` — "getGoal retrieves a goal by id", "getGoal returns null for non-existent goal", "getAllGoals returns all goals", "getActiveGoals returns only incomplete goals" | `lib/src/services/education_goal_service.dart` · `lib/src/ui/screens/goals_list_screen.dart` | — |
| FR-1.7 | View goal detail | OBJECTIVES.md FR-1.1 | None — gap | `lib/src/ui/screens/goal_detail_screen.dart` · `lib/src/ui/widgets/goal_card.dart` | — |

---

## FR-2 · Learning Paths

| ID | Feature | Product Spec | Tests | Implementation | Release Gate |
|----|---------|-------------|-------|----------------|--------------|
| FR-2.1 | Create structured learning paths | OBJECTIVES.md FR-2.1 | None — gap (planned) | `lib/src/models/resource.dart` | — |
| FR-2.2 | Add courses/resources to paths | OBJECTIVES.md FR-2.2 | None — gap | `lib/src/services/resource_service.dart` · `lib/src/ui/screens/resource_library_screen.dart` | — |
| FR-2.3 | Define prerequisites and dependencies | OBJECTIVES.md FR-2.3 | None — gap | Planned | — |
| FR-2.4 | Track path completion progress | OBJECTIVES.md FR-2.4 | None — gap | `lib/src/ui/widgets/progress_bar.dart` | — |
| FR-2.5 | Clone/share learning paths | OBJECTIVES.md FR-2.5 | None — gap | Planned | — |

---

## FR-3 · Activities

| ID | Feature | Product Spec | Tests | Implementation | Release Gate |
|----|---------|-------------|-------|----------------|--------------|
| FR-3.1 | Schedule study activities with duration | OBJECTIVES.md FR-3.1 | `test/models/activity_test` — "creates an activity with required fields", "creates an activity with optional fields" | `lib/src/models/activity.dart` · `lib/src/ui/screens/activity_form_dialog.dart` | — |
| FR-3.2 | Set duration and reminders | OBJECTIVES.md FR-3.2 | `test/models/activity_test` — "creates an activity with optional fields" | `lib/src/models/activity.dart` | — |
| FR-3.3 | Link activities to goals | OBJECTIVES.md FR-3.3 | None — gap | `lib/src/models/activity.dart` | — |
| FR-3.4 | Mark activities complete | OBJECTIVES.md FR-3.4 | `test/models/weekly_plan_test` — "completedActivities returns only completed activities", "pendingActivities returns only pending activities" | `lib/src/models/activity.dart` · `lib/src/models/weekly_plan.dart` · `lib/src/ui/widgets/activity_card.dart` | — |
| FR-3.5 | Log actual time spent | OBJECTIVES.md FR-3.5 | None — gap | `lib/src/models/activity.dart` | — |
| FR-3.6 | Activity JSON serialisation round-trip | OBJECTIVES.md FR-3.1 | `test/models/activity_test` — "toJson converts activity to JSON", "fromJson creates activity from JSON", "fromJson handles missing optional fields", "copyWith creates a new instance with updated fields" | `lib/src/models/activity.dart` | — |

---

## FR-4 · Weekly Planning

| ID | Feature | Product Spec | Tests | Implementation | Release Gate |
|----|---------|-------------|-------|----------------|--------------|
| FR-4.1 | Create weekly study plans (Mon–Sun) | OBJECTIVES.md FR-4.1 | `test/models/weekly_plan_test` — "creates a plan with required fields", "weekEndDate returns correct Sunday" | `lib/src/models/weekly_plan.dart` · `lib/src/services/weekly_plan_service.dart` · `lib/src/ui/screens/weekly_plan_screen.dart` | — |
| FR-4.2 | Add / remove activities across days | OBJECTIVES.md FR-4.2 | `test/models/weekly_plan_test` — "addActivity adds an activity to the plan", "removeActivity removes an activity from the plan", "removeActivity returns false for non-existent activity" | `lib/src/models/weekly_plan.dart` · `lib/src/services/weekly_plan_service.dart` | — |
| FR-4.3 | View completion percentage | OBJECTIVES.md FR-4.3 | `test/models/weekly_plan_test` — "completionPercentage calculates correctly", "completionPercentage returns 0 for empty plan", "totalPlannedMinutes calculates total duration" | `lib/src/models/weekly_plan.dart` · `lib/src/ui/screens/weekly_plan_screen.dart` | — |
| FR-4.4 | Reschedule incomplete activities | OBJECTIVES.md FR-4.4 | None — gap | `lib/src/services/weekly_plan_service.dart` | — |
| FR-4.5 | Weekly plan JSON round-trip | OBJECTIVES.md FR-4.1 | `test/models/weekly_plan_test` — "toJson converts plan to JSON", "fromJson creates plan from JSON", "copyWith creates a new instance with updated fields" | `lib/src/models/weekly_plan.dart` | — |

---

## FR-5 · Resources

| ID | Feature | Product Spec | Tests | Implementation | Release Gate |
|----|---------|-------------|-------|----------------|--------------|
| FR-5.1 | Store links, notes, and materials | OBJECTIVES.md FR-5.1 | None — gap | `lib/src/models/resource.dart` · `lib/src/services/resource_service.dart` · `lib/src/ui/screens/resource_library_screen.dart` · `lib/src/ui/screens/resource_form_dialog.dart` | — |
| FR-5.2 | Categorize by subject/course | OBJECTIVES.md FR-5.2 | None — gap | `lib/src/models/resource.dart` | — |
| FR-5.3 | Rate and review resources | OBJECTIVES.md FR-5.3 | None — gap | `lib/src/models/resource.dart` | — |
| FR-5.4 | Search and filter | OBJECTIVES.md FR-5.4 | None — gap | `lib/src/ui/screens/search_screen.dart` · `lib/src/ui/widgets/filter_chips.dart` | — |

---

## Additional Implemented Features (not yet in OBJECTIVES.md)

| Feature | Tests | Implementation |
|---------|-------|----------------|
| Knowledge notes (create, view, search) | None | `lib/src/models/knowledge_note.dart` · `lib/src/services/knowledge_note_service.dart` · `lib/src/ui/screens/notes_list_screen.dart` · `lib/src/ui/screens/note_detail_screen.dart` · `lib/src/ui/screens/note_form_dialog.dart` · `lib/src/ui/screens/knowledge_dashboard_screen.dart` |
| Spaced repetition (review cards) | None | `lib/src/models/review_card.dart` · `lib/src/services/spaced_repetition_service.dart` · `lib/src/ui/screens/review_session_screen.dart` · `lib/src/ui/screens/daily_review_screen.dart` |
| SQLite local database | None | `lib/src/services/database_service.dart` |

---

## Coverage Summary

| FR Group | Sub-features | Tests | Gaps |
|----------|-------------|-------|------|
| FR-1 Goals | 7 | Service + model tests good | Milestone, progress %, categories untested |
| FR-2 Learning Paths | 5 | None | Entire group — mostly planned |
| FR-3 Activities | 6 | Model tests good | Goal linking, time logging, UI untested |
| FR-4 Weekly Planning | 5 | Model tests comprehensive | Reschedule, UI screen untested |
| FR-5 Resources | 4 | None | All untested |
| Knowledge Notes | — | None | No tests for implemented feature |
| Spaced Repetition | — | None | No tests for implemented feature |

> **Priority gaps**: Add `test/services/weekly_plan_service_test` for reschedule; add widget tests for `goals_list_screen`, `weekly_plan_screen`, and `resource_library_screen`; add service tests for `knowledge_note_service` and `spaced_repetition_service`.

## Integration Test Coverage

`integration_test/app_test.dart` covers:
- App loads and initialises without crashing
- Loading state resolves to main shell
- Bottom navigation bar is present
- Goals tab is present and selectable
- Plans tab is present and selectable
- Notes tab is present
- Library tab is present
- Tapping Plans / Notes / Library tabs switches content
- Cycling through all tabs does not crash
- Returning to Goals tab restores goals screen
- Goals screen shows empty state or goal list
- Rapid tab switches do not crash app

## Workflow Documentation

Primary user journeys documented in `docs/WORKFLOWS.md`:
- Workflow 1: Goal Management (create, track, complete)
- Workflow 2: Weekly Study Planning
- Workflow 3: Notes
- Workflow 4: Resource Library
- Workflow 5: Daily Review
- Workflow 6: Spaced Repetition (planned)
- Workflow 7: Focus Training Integration
