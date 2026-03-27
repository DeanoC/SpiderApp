# Package Commands

Manage Spiderweb venom packages through the canonical workspace package surface:

- `/.spiderweb/control/packages`

These commands run through the selected or attached workspace context, then talk to Spiderweb's package lifecycle controls over the mounted filesystem surface.

## Commands

- `spider package list`
- `spider package catalog [package_id] [--channel stable|beta|dev]`
- `spider package updates`
- `spider package update <package_id> [--channel stable|beta|dev] [--release <version>] [--activate]`
- `spider package update-all [package_id ...] [--apply] [--activate]`
- `spider package info|get <package_id> [--source installed|registry] [--channel <channel>] [--release <version>]`
- `spider package install <package_id> [--channel <channel>] [--release <version>]`
- `spider package install <json_or_@file>`
- `spider package channel-get [package_id]`
- `spider package channel-set <channel> [package_id]`
- `spider package channel-clear <package_id>`
- `spider package enable <package_id>`
- `spider package switch <package_id> <release_version>`
- `spider package disable <package_id>`
- `spider package rollback <package_id> [release_version]`
- `spider package remove <package_id> [release_version]`

## Examples

```bash
spider package list
spider package updates
spider package info terminal
spider package info browser --source registry --channel beta
spider package install browser
spider package install browser --channel beta
spider package update browser --activate
spider package update-all --apply --activate
spider package channel-get
spider package channel-set beta
spider package channel-set dev browser
spider package channel-clear browser
spider package switch browser 0.5.8
spider package rollback browser
spider package install @scratchpad-release.json
```

## Notes

- `list` shows installed package state plus registry metadata such as latest release, effective channel, and update availability.
- `catalog` reads the signed hosted registry view without installing anything.
- `updates` is discovery-only. Use `update` or `update-all --apply` to actually install updates.
- `install <package_id>` defaults to the hosted registry source. `install <json_or_@file>` keeps the raw JSON install path for local/dev payloads.
- `channel-set <channel>` with no package ID changes the host default channel. Adding a package ID creates a package override.
- `rollback` without a release version chooses the next lower installed release when one exists.
