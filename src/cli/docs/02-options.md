# Global Options

## Connection Options

### `--url <url>`
Spiderweb server WebSocket URL.

**Default:** `ws://127.0.0.1:18790`

**Examples:**
```bash
spider --url ws://100.101.192.123:18790 chat send "Hello"
spider --url ws://localhost:18790 project list
```

### `--project <project_id>`
Set the current project for this session.

**Examples:**
```bash
spider --project spiderweb goal list
spider --project mygame chat send "What's next?"
```

### `--project-token <token>`
Project token used for `control.project_activate`.

If provided with `project use`, the token is also persisted in local config for that project.

**Examples:**
```bash
spider --project proj-1 --project-token proj-abc workspace status
spider --project-token proj-abc project use proj-1
```

### `--operator-token <token>`
Operator token used for protected control mutations (for example `control.project_create`).

If omitted, ZSS uses the saved admin role token when available.

### `--role <admin|user>`
Select which saved role token is used for connection/auth on this command.

If omitted, ZSS uses the locally saved active role.

**Examples:**
```bash
spider --operator-token op-secret project create demo "Distributed workspace"
spider --operator-token op-secret project create "Game AI"
```

## Mode Options

### `--interactive`
Start interactive REPL mode instead of running a single command.

Note: the interactive REPL is not implemented yet; command mode is currently required.

**Examples:**
```bash
spider --interactive
spider --url ws://remote:18790 --interactive
```

### `--verbose`
Enable verbose debug logging.

**Examples:**
```bash
spider --verbose chat send "Test"
spider --verbose --interactive
```

## Information Options

### `--help`
Show help message and exit.

### `--version`
Show version information and exit.
