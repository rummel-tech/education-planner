# Education Planner Deployment

## Overview

The Education Planner is currently a Python CLI application. This guide covers local installation and usage.

## Installation

```bash
cd modules/planners/education-planner
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Usage

```bash
# Run the application
python -m education_planner

# Run tests
pytest
```

## Configuration

Configuration is managed via environment variables or a `.env` file:

```bash
DATABASE_URL=sqlite:///./education_planner.db
```

## Future Deployment

When Flutter frontend and FastAPI backend are added:
- Frontend: GitHub Pages via infrastructure workflows
- Backend: AWS ECS via infrastructure workflows

---

[Back to Module](../) | [Platform Documentation](../../../../docs/)
