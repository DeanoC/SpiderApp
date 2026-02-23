# ZiggyStarSpider CLI

## Usage

```text
ziggystarspider <noun> <verb> [args] [options]
ziggystarspider --help
```

## Noun-Verb Commands

- `chat send <message>` - Send a message to the AI
- `chat history` - Show recent chat history
- `fs ls <path>` - List entries for a virtual filesystem path
- `fs tree <path>` - Alias of `fs ls` for directory-style browsing
- `fs read <path>` - Read a virtual filesystem file
- `fs write <path> <content>` - Write text to a virtual filesystem file
- `fs stat <path>` - Show file metadata for a virtual filesystem path
- `project list` - List all projects
- `project use <project_id> [project_token]` - Select/activate a project
- `project info <project_id>` - Show project details
- `project create <name> [vision]` - Create a project and store selection/token locally
- `node list` - List registered nodes
- `node info <node_id>` - Show node details
- `workspace status [project_id]` - Show active workspace mounts
- `goal list` - List goals for current project
- `goal create <description>` - Create a new goal
- `task list` - List active tasks
- `worker list` - Show running workers
- `connect` - Connect to Spiderweb
- `disconnect` - Disconnect from Spiderweb

## Global Options

- `--url <url>` - Spiderweb server URL (default: ws://127.0.0.1:18790)
- `--project <project_id>` - Set current project
- `--project-token <token>` - Token used to activate project context
- `--operator-token <token>` - Token for operator-scoped control mutations (for example `project create`)
- `--interactive` - Start interactive REPL mode
- `--verbose` - Enable verbose logging
- `--help` - Show this help
- `--version` - Show version

## Interactive Mode

Interactive mode entry exists, but the REPL is not implemented yet.

Current behavior:

```
ziggystarspider --url ws://100.101.192.123:18790

Interactive mode not yet implemented.
Use command mode for now.
```

## Design Philosophy

ZSS uses a noun-verb command structure:
- **Noun** = What you're acting on (chat, project, goal, task)
- **Verb** = What you're doing (send, list, create, use)

This makes commands discoverable and consistent.
