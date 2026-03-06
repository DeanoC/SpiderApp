# Pairing Commands

Pairing commands operate on the Acheron pairing queue and invite registry exposed in WorldFS debug paths.

If an operator token is configured (`--operator-token` or local config), it is added automatically to pairing control writes.

## pairing pending

Refresh and list pending join requests.

**Examples:**
```bash
spider pairing pending
```

## pairing approve <request_id> [--lease-ttl-ms <ms>]

Approve one pending request.

**Arguments:**
- `request_id` - Pairing request identifier

**Options:**
- `--lease-ttl-ms <ms>` - Optional lease TTL override in milliseconds

**Examples:**
```bash
spider pairing approve pending-join-1
spider pairing approve pending-join-1 --lease-ttl-ms 900000
```

## pairing deny <request_id>

Deny one pending request.

**Arguments:**
- `request_id` - Pairing request identifier

**Examples:**
```bash
spider pairing deny pending-join-1
```

## pairing list

Refresh and list active pairing invites.

**Examples:**
```bash
spider pairing list
```

## pairing create [--expires-in-ms <ms>]

Create a new pairing invite.

**Options:**
- `--expires-in-ms <ms>` - Optional invite TTL in milliseconds

**Examples:**
```bash
spider pairing create
spider pairing create --expires-in-ms 600000
```

## pairing refresh [pending|invites|all]

Refresh pairing snapshots and print selected view(s).

- Default target is `all`.
- `pending` refreshes pending requests only.
- `invites` refreshes invite list only.

**Examples:**
```bash
spider pairing refresh
spider pairing refresh pending
spider pairing refresh invites
```
