# Connection Commands

## connect

Connect to Spiderweb server.

Connection uses unified-v2 control negotiation:
`control.version` (`protocol=unified-v2`) then `control.connect`.

**Options:**
- `--url <url>` - Server URL (required if not configured)

**Examples:**
```bash
ziggystarspider connect
ziggystarspider connect --url ws://100.101.192.123:18790
```

## disconnect

Disconnect from Spiderweb server.

**Examples:**
```bash
ziggystarspider disconnect
```

## status

Show connection status.

**Examples:**
```bash
ziggystarspider status
```

**Output:**
```
Connected: Yes
Server: ws://100.101.192.123:18790
Project: spiderweb
Uptime: 45 minutes
```
