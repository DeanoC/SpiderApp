# Project Commands

Projects are the top-level organization for work in Spiderweb.

## project list

List all projects.

**Examples:**
```bash
ziggystarspider project list
```

**Output (example):**
```
Projects:
  proj-1  [active]  mounts=2  name=Spiderweb
* proj-2  [active]  mounts=1  name=Game AI
```

## project use <project_id> [project_token]

Select a project and optionally activate it.

**Arguments:**
- `project_id` - Project id (for example `proj-1`)
- `project_token` (optional) - Project token for activation

**Examples:**
```bash
ziggystarspider project use proj-1
ziggystarspider project use proj-1 proj-abc123
ziggystarspider --project-token proj-abc123 project use proj-1
```

## project create <name> [vision]

Create a new project and persist it as the selected project in local config.

**Arguments:**
- `name` - Project display name
- `vision` (optional) - Freeform vision/description text

**Examples:**
```bash
ziggystarspider project create "Distributed Workspace"
ziggystarspider project create "Distributed Workspace" "unified node mounts"
ziggystarspider --operator-token op-secret project create "Secure Project"
```

## project info <project_id>

Show information about a project.

**Examples:**
```bash
ziggystarspider project info proj-1
```

**Output (example):**
```
Project proj-1
  Name: Distributed Workspace
  Vision: unified node mounts
  Status: active
  Created: 1739999999999
  Updated: 1739999999999
  Mounts (2):
    - /src <= node-a:work
    - /cache <= node-b:cache
```

## project up <name>

Create/update and activate a project with desired mounts in one command.

**Examples:**
```bash
ziggystarspider project up "Distributed Workspace"
ziggystarspider project up "Distributed Workspace" --mount /workspace=node-1:work
```

## project doctor

Run readiness checks for nodes, project selection, and active mounts.

**Examples:**
```bash
ziggystarspider project doctor
ziggystarspider --project proj-1 project doctor
```
