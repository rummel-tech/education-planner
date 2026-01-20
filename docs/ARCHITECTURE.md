# Education Planner Architecture

## Overview

The Education Planner is a Python application for managing learning paths, tracking course progress, and scheduling study sessions.

## System Components

```
┌─────────────────────┐
│  Education Planner  │
│   (Python CLI)      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   SQLite Database   │
└─────────────────────┘
```

## Project Structure

```
education-planner/
├── src/
│   ├── models/             # Data models
│   ├── services/           # Business logic
│   └── utils/              # Utilities
├── tests/                  # Pytest suite
├── requirements.txt        # Dependencies
└── README.md
```

## Data Models

### LearningPath
- id, name, description
- courses, milestones
- start_date, target_date

### Course
- id, title, provider
- status (not_started/in_progress/completed)
- resources, notes

### StudySession
- id, course_id
- scheduled_time, duration
- topic, notes

## Services

### LearningPathService
- Create and manage learning paths
- Track progress across courses
- Generate progress reports

### StudyScheduler
- Schedule study sessions
- Send reminders
- Track study time

## Future Enhancements

- Flutter frontend for cross-platform UI
- FastAPI backend for web access
- Spaced repetition integration
- External course provider integrations

## Related Documentation

- [Module README](../README.md)
- [Platform Architecture](../../../../docs/ARCHITECTURE.md)

---

[Back to Module](../) | [Platform Documentation](../../../../docs/)
