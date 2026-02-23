# Global Options

## Connection Options

### `--url <url>`
Spiderweb server WebSocket URL.

**Default:** `ws://127.0.0.1:18790`

**Examples:**
```bash
ziggystarspider --url ws://100.101.192.123:18790 chat send "Hello"
ziggystarspider --url ws://localhost:18790 project list
```

### `--project <project_id>`
Set the current project for this session.

**Examples:**
```bash
ziggystarspider --project spiderweb goal list
ziggystarspider --project mygame chat send "What's next?"
```

### `--project-token <token>`
Project token used for `control.project_activate`.

If provided with `project use`, the token is also persisted in local config for that project.

**Examples:**
```bash
ziggystarspider --project proj-1 --project-token proj-abc workspace status
ziggystarspider --project-token proj-abc project use proj-1
```

### `--operator-token <token>`
Operator token used for protected control mutations (for example `control.project_create`).

If omitted, ZSS uses the saved config auth token when available.

**Examples:**
```bash
ziggystarspider --operator-token op-secret project create demo "Distributed workspace"
ziggystarspider --operator-token op-secret project create "Game AI"
```

## Mode Options

### `--interactive`
Start interactive REPL mode instead of running a single command.

Note: the interactive REPL is not implemented yet; command mode is currently required.

**Examples:**
```bash
ziggystarspider --interactive
ziggystarspider --url ws://remote:18790 --interactive
```

### `--verbose`
Enable verbose debug logging.

**Examples:**
```bash
ziggystarspider --verbose chat send "Test"
ziggystarspider --verbose --interactive
```

## Information Options

### `--help`
Show help message and exit.

### `--version`
Show version information and exit.
