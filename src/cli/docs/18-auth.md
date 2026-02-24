# Auth Commands

Inspect and rotate Spiderweb auth tokens.

These commands require an admin token for access.

## auth status

Show current admin/user tokens and backing storage path from Spiderweb.
By default token values are masked.

```bash
ziggystarspider auth status
ziggystarspider --role admin auth status
ziggystarspider auth status --reveal
ziggystarspider --operator-token sw-admin-... auth status
```

## auth rotate <admin|user>

Rotate one token role.

- `admin` rotates and stores the local admin token.
- `user` rotates and stores the local user token.
- Output is masked by default; add `--reveal` to print full token.

```bash
ziggystarspider auth rotate admin
ziggystarspider auth rotate user --reveal
```
