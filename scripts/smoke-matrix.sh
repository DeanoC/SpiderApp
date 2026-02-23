#!/usr/bin/env bash
# Distributed workspace CLI/GUI smoke matrix for ZiggyStarSpider.
# Covers connect, project, node, workspace, filesystem, and chat flows.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSS_BIN="${ZSS_BIN:-$ROOT_DIR/zig-out/bin/zss}"
SPIDERWEB_URL="${SPIDERWEB_URL:-ws://127.0.0.1:18790}"
SMOKE_PROJECT_NAME="${SMOKE_PROJECT_NAME:-zss-smoke-$(date +%s)}"
SMOKE_CHAT_PROMPT="${SMOKE_CHAT_PROMPT:-smoke test: summarize active project mounts in one sentence}"
SMOKE_SKIP_BUILD="${SMOKE_SKIP_BUILD:-0}"
SMOKE_SKIP_GUI_BUILD="${SMOKE_SKIP_GUI_BUILD:-0}"
SMOKE_SKIP_CHAT="${SMOKE_SKIP_CHAT:-0}"

log() {
    printf '[smoke] %s\n' "$1"
}

run_cli() {
    log "zss $*"
    "$ZSS_BIN" --url "$SPIDERWEB_URL" "$@"
}

if [[ "$SMOKE_SKIP_BUILD" != "1" ]]; then
    log "building CLI"
    (cd "$ROOT_DIR" && zig build)
fi

if [[ ! -x "$ZSS_BIN" ]]; then
    printf '[smoke] missing CLI binary: %s\n' "$ZSS_BIN" >&2
    exit 1
fi

if [[ "$SMOKE_SKIP_GUI_BUILD" != "1" ]]; then
    log "building GUI artifact"
    (cd "$ROOT_DIR" && zig build gui)
fi

log "connect + topology checks"
run_cli connect
run_cli node list

log "project bootstrap and validation"
run_cli project up "$SMOKE_PROJECT_NAME"
run_cli project doctor
run_cli project list
run_cli --verbose workspace status

log "filesystem checks"
run_cli fs ls /
run_cli fs tree / --max-depth 2
run_cli fs ls /capabilities
run_cli fs read /capabilities/chat/control/help

if [[ "$SMOKE_SKIP_CHAT" != "1" ]]; then
    log "chat capability check"
    run_cli chat send "$SMOKE_CHAT_PROMPT"
else
    log "chat check skipped (SMOKE_SKIP_CHAT=1)"
fi

log "smoke matrix completed successfully"
