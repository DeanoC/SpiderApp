# Session Commands

Session commands operate on unified-v2 control-plane session bindings.

## session list

List known sessions on the current connection and show the active session.

**Examples:**
```bash
spider session list
```

## session history [agent_id] [--limit <n>]

List persisted sessions recorded by Spiderweb for this auth role (newest first).

**Examples:**
```bash
spider session history
spider session history spiderweb --limit 5
```

## session status [session_key]

Show attach/runtime state for a session. Without `session_key`, uses the active session.

**Examples:**
```bash
spider session status
spider session status main
```

## session attach <session_key> <agent_id> [--workspace <workspace_id>] [--workspace-token <token>]

Create or rebind a session to an agent and workspace context.

**Examples:**
```bash
spider session attach review spiderweb --workspace system
spider session attach work bob --workspace ws-demo --workspace-token ws-secret
```

## session resume <session_key>

Switch the active session to an existing session key.

**Examples:**
```bash
spider session resume main
spider session resume review
```

## session close <session_key>

Close a non-`main` session.

**Examples:**
```bash
spider session close review
```

## session restore [agent_id]

Find the most recent persisted session (optionally for one agent) and attach it.

**Examples:**
```bash
spider session restore
spider session restore spiderweb
```
