# Workspace Commands

Workspace status shows the currently effective project mounts for the current agent.

## workspace status [project_id]

Show workspace root and mounted node exports.

**Arguments:**
- `project_id` (optional) - Resolve status for a specific project

**Examples:**
```bash
ziggystarspider workspace status
ziggystarspider --verbose workspace status
ziggystarspider workspace status proj-1
ziggystarspider --project proj-1 workspace status
```

`--verbose` also prints reconcile diagnostics (`state`, `queue_depth`, `failed_ops`, totals).
