# ZiggyStarSpider Troubleshooting

## Auth Failures

Symptoms:
- control mutations fail (`Unauthorized`, `OperatorAuthFailed`, `ProjectAuthFailed`)
- project activation fails

Checks:
- verify `--operator-token` for operator-scoped mutations
- verify project token used by `project use` / `project activate`
- confirm selected project token in local config matches server token

Actions:
- rotate/reissue token server-side, then update local token
- retry command with explicit token flags

## No Nodes / Lease Expiry

Symptoms:
- `node list` empty
- workspace shows no actual mounts
- drift increases after node drop

Checks:
- `zss node list`
- `zss --verbose workspace status` (drift + reconcile diagnostics)

Actions:
- rejoin nodes to Spiderweb
- refresh workspace / run `project doctor`
- verify node lease refresh path is healthy

## Mount Conflicts / Missing Mounts

Symptoms:
- `project up` or mount mutations fail with conflict-style errors
- workspace mount set diverges from desired

Checks:
- inspect desired vs actual vs drift in `workspace status`
- check mount path overlap in project configuration

Actions:
- adjust conflicting mount paths
- re-run `project up` with corrected desired mounts
- refresh workspace and confirm drift count returns to zero

## Reconcile Stuck / Degraded

Symptoms:
- `reconcile_state` remains `degraded`
- `queue_depth` or `failed_ops_total` keeps growing

Checks:
- `zss --verbose workspace status`
- inspect reconcile `failed_ops` and `last_error`

Actions:
- fix failing node/project references in desired mounts
- verify required auth tokens for mutations
- trigger refresh and observe `reconcile_state` transition back to `idle`

## Chat Send Interrupted

Symptoms:
- send fails during reconnect/timeout
- user message remains pending

Checks:
- reconnect GUI/CLI session
- inspect queued jobs:
  - `zss chat resume`
  - `zss chat resume <job-id>`

Actions:
- allow automatic resume after reconnect
- manually resume by job id if needed

## Filesystem Browser Issues (GUI)

Symptoms:
- filesystem panel shows errors or empty results

Checks:
- confirm connected state in Settings
- ensure project is selected/activated
- test same paths from CLI (`fs ls`, `fs read`)

Actions:
- use `Refresh` in filesystem panel
- reset to workspace root in panel
- verify mounts exist in workspace status

## Debugging Aids

- Enable Debug Stream panel in GUI for control/fsrpc events and correlation IDs.
- Use CLI `--verbose` for workspace diagnostics.
- Run `./scripts/smoke-matrix.sh` for a full workflow check.
