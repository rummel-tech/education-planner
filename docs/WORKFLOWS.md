# Education Planner — Primary Workflows

Documents the main user-facing journeys through the Education Planner app.

---

## Navigation Structure

The app uses a bottom **NavigationBar** with five tabs:

| Tab | Icon | Screen |
|-----|------|--------|
| Goals | school | GoalsListScreen |
| Plans | calendar_today | WeeklyPlanScreen |
| Notes | note | NotesListScreen |
| Library | library_books | ResourceLibraryScreen |
| Review | checklist | DailyReviewScreen |

---

## 1. Goal Management (Primary Workflow)

The central workflow: create a learning goal, build a path to reach it, schedule activities, and track progress.

### Step 1: Create a Goal
**Entry:** Goals tab → "+"

1. Enter title (e.g. "Learn Rust", "Complete AWS cert")
2. Set category: professional, personal, or hobby
3. Set target date
4. Add optional description
5. Save → goal appears in Goals list at 0% progress

### Step 2: Track Progress
- Goal card shows progress percentage (0–100%)
- Progress updates as linked activities are completed
- Tap a goal to view its associated activities and notes

### Step 3: Complete a Goal
- Tap goal → **Mark complete**
- Goal moves to completed section

---

## 2. Weekly Study Planning

### Step 1: Open Weekly Plan
**Entry:** Plans tab

- Shows current week (Mon–Sun)
- Each day shows scheduled study activities

### Step 2: Add a Study Activity
**Entry:** Plans tab → "+" on a day

1. Enter title (e.g. "Read Chapter 4", "Practice Leetcode")
2. Set duration (e.g. 45 min)
3. Link to a goal (optional)
4. Set reminder (optional)
5. Save → activity appears on the day

### Step 3: Complete Activities
- Tap an activity → **Mark complete**
- Weekly completion percentage updates

### Step 4: Review Week
- View completion rate across the week
- Incomplete activities can be rolled over to the next week

---

## 3. Notes

**Entry:** Notes tab

- Create text notes linked to goals or free-form
- Notes support markdown formatting
- Search notes by keyword
- Useful for: lecture notes, reading summaries, code snippets

---

## 4. Resource Library

**Entry:** Library tab

- Store links, articles, videos, and documents
- Categorise by subject or course
- Rate resources (star rating)
- Filter by category or rating
- Link resources to specific goals

---

## 5. Daily Review

**Entry:** Review tab

- Summary of today's scheduled activities
- Mark activities complete from this view
- See overdue activities from previous days
- Log actual time spent on each activity

---

## 6. Spaced Repetition (Planned)

- Create flashcard decks linked to goals
- System schedules review sessions based on recall performance
- Integrates with Focus Training for timed study sessions

---

## 7. Focus Training Integration

When a study activity is started:
1. Education Planner passes activity context to Focus Training
2. Focus Training starts a timed session
3. Focus score recorded on session completion
4. Focus score linked back to the activity in Education Planner

---

## 8. Typical Day Workflow

```
Daily Review tab
    → See today's activities
    → Tap "Start" on a study activity
        → (Optional) Launch focus session in Focus Training
        → Study
        → Mark activity complete
    → Review progress on Goals tab
    → Add notes in Notes tab
```
