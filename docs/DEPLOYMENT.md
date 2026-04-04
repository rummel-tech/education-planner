# Education Planner deployment

## Overview

The app is a **Flutter** client with a **FastAPI** backend under `services/education-planner/` in the monorepo.

## Backend (local)

```bash
cd services/education-planner
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
pip install -e ../common
uvicorn main:app --reload --port 8050
```

## Frontend (local)

```bash
cd education-planner
flutter pub get
flutter build web --release   # or flutter run -d chrome
```

## Production

Use the same patterns as other platform apps: container image for the API (ECS), static hosting for Flutter web, secrets in AWS Secrets Manager. Trigger workflows from `infrastructure/.github/workflows/` on your infrastructure remote when those pipelines exist for this service.

---

**Last updated**: April 2026
