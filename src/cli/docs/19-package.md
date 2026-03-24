# Package Commands

Manage Spiderweb venom packages through the canonical workspace control surface:

- `/.spiderweb/control/packages`

These commands operate through the mounted workspace filesystem, so they use the currently selected or attached workspace context.

## Commands

- `spider package list`
- `spider package info <package_id>`
- `spider package install <json_or_@file>`
- `spider package enable <package_id>`
- `spider package disable <package_id>`
- `spider package remove <package_id>`

## Examples

```bash
spider package list
spider package info terminal
spider package disable search_code
spider package enable search_code
spider package remove scratchpad
spider package install '{"package":{"venom_id":"scratchpad","kind":"memory_ext","version":"1","host_roles":["client"],"binding_scopes":["agent"],"runtime_kind":"native","requirements":{"venoms":["memory"]},"capabilities":{"invoke":true},"ops":{"model":"filesystem_loopback"},"runtime":{"type":"external_runtime"},"permissions":{},"schema":{}}}'
spider package install @scratchpad-package.json
```

## Notes

- `list` shows both enabled and disabled packages from the control substrate.
- Disabled packages are hidden from the agent-facing capability catalog until re-enabled.
- Built-in packages are protected from `install`, `enable`, `disable`, and `remove` mutations when Spiderweb marks them as builtin-protected.
