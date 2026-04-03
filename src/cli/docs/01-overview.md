# SpiderApp CLI

## Usage

```text
spider <noun> <verb> [args] [options]
spider --help
```

## Noun-Verb Commands

- `chat send <message>` - Send a message to the AI
- `chat history` - Show recent chat history
- `chat resume [job_id]` - Resume/inspect queued chat jobs
- `fs ls <path>` - List entries for a virtual filesystem path
- `fs tree [path] [--max-depth N] [--files-only|--dirs-only]` - Recursive directory walk
- `fs read <path>` - Read a virtual filesystem file
- `fs write <path> <content>` - Write text to a virtual filesystem file
- `fs stat <path>` - Show file metadata for a virtual filesystem path
- `workspace list` - List all workspaces
- `workspace use <workspace_id> [workspace_token]` - Select/activate a workspace
- `workspace info <workspace_id>` - Show workspace details
- `workspace create <name> [vision]` - Create a workspace and store selection/token locally
- `workspace up <name>` - One-shot workspace + mount bootstrap
- `workspace doctor` - Readiness checks with actionable failures
- `workspace template list` - List available workspace templates
- `workspace template info <template_id>` - Show one template and its binds
- `workspace bind list [workspace_id]` - List workspace binds
- `workspace bind add <bind_path> <target_path>` - Add a workspace bind
- `workspace bind remove <bind_path>` - Remove a workspace bind
- `workspace mount list [workspace_id]` - List workspace mounts
- `workspace mount add <mount_path> <node_id> <export_name>` - Add a workspace mount
- `workspace mount remove <mount_path> [node_id export_name]` - Remove a workspace mount
- `workspace handoff show [generic|codex_app|spider_monkey]` - Print runtime handoff commands
- `package list` - List installed packages with active/latest release and channel state
- `package catalog [package_id] [--channel <channel>]` - Show registry-visible packages/releases
- `package updates` - Show available registry updates for installed packages
- `package update <package_id> [--channel <channel>] [--release <version>] [--activate]` - Install one package update
- `package update-all [package_id ...] [--apply] [--activate]` - Preview or apply multiple package updates
- `package info|get <package_id>` - Show installed or registry package details
- `package install <package_id> [--channel <channel>] [--release <version>]` - Install latest registry package
- `package install <json_or_@file>` - Install a raw package/release JSON payload
- `package channel-get [package_id]` - Show host default or package-specific channel policy
- `package channel-set <channel> [package_id]` - Set host default channel or package override
- `package channel-clear <package_id>` - Clear a package-specific channel override
- `package enable <package_id>` - Re-enable an installed package
- `package switch <package_id> <release_version>` - Switch the active installed release
- `package disable <package_id>` - Disable an installed package from discovery/use
- `package rollback <package_id> [release_version]` - Roll back to a prior installed release
- `package remove <package_id> [release_version]` - Remove an installed package or one installed release
- `agent list` - List discoverable agents
- `agent info <agent_id>` - Show one agent's metadata
- `session list` - List known sessions for this connection
- `session history [agent_id] [--limit N]` - List persisted sessions
- `session status [session_key]` - Show attach/runtime state for a session
- `session attach <session_key> <agent_id>` - Create/rebind a session
- `session resume <session_key>` - Switch active session
- `session close <session_key>` - Close a non-main session
- `session restore [agent_id]` - Attach the latest persisted session
- `node list` - List registered nodes
- `node info <node_id>` - Show node details
- `node invite-create` - Create an invite token for a Linux node
- `node join-request <node_name> [fs_url]` - Submit pending node join request
- `node pending` - List pending node join requests
- `node approve <request_id>` - Approve pending node join request
- `node deny <request_id>` - Deny pending node join request
- `node service-get <node_id>` - Show node service catalog
- `node service-upsert <node_id> <node_secret>` - Update node service catalog metadata
- `node service-runtime <node_id> <service_id> <action>` - Read/write runtime control files for a service mount
- `server install` - Install or update Spiderweb as a Linux service
- `server status` - Show Linux Spiderweb status
- `server doctor` - Show Linux Spiderweb health and next step
- `server remove` - Remove the Linux Spiderweb service
- `local-node install` - Install Linux node scaffolding
- `local-node connect` - Connect this Linux machine to another Spiderweb
- `local-node status` - Show Linux node status
- `local-node remove` - Remove the Linux node service and local config
- `workspace status [workspace_id]` - Show active workspace mounts
- `auth status` - Show Spiderweb auth token status (admin only)
- `auth rotate <admin|user>` - Rotate Spiderweb auth token (admin only)
- `connect` - Connect to Spiderweb
- `disconnect` - Disconnect from Spiderweb

## Global Options

- `--url <url>` - Spiderweb server URL (default: ws://127.0.0.1:18790)
- `--workspace <workspace_id>` - Set current workspace
- `--workspace-token <token>` - Token used to activate workspace context
- `--operator-token <token>` - Token for operator-scoped control mutations (for example `workspace create`)
- `--role <admin|user>` - Select saved auth role token for this command
- `--interactive` - Start interactive REPL mode
- `--verbose` - Enable verbose logging
- `--help` - Show this help
- `--version` - Show version

## Which CLI To Use

- Use `spider` for day-to-day user workflows: connect, choose a workspace, attach sessions, inspect nodes, and work with chat/filesystem flows.
- Use Spiderweb's `control_cli` when you need raw `control.*` requests, protocol debugging, or transport-level inspection.
- Use SpiderNode's `fs_node_main` when you need to run or pair a node daemon; it is not a general operator workflow CLI.

## Interactive Mode

On Linux, running `spider` with no subcommand from a real terminal opens the guided Linux home.

That guided home offers:

- `Host Spiderweb Here`
- `Connect This Linux Machine`
- `Status / Repair`

Use `spider --interactive` only when you explicitly want the REPL path.

Current behavior:

```
spider

Spider Linux Home
```

## Design Philosophy

SpiderApp CLI uses a noun-verb command structure:
- **Noun** = What you're acting on (chat, workspace, node, session)
- **Verb** = What you're doing (send, list, create, use)

This makes commands discoverable and consistent.
