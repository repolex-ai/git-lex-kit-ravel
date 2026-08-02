#!/bin/bash
# SessionEnd hook (ravel kit) — back up + ingest this soul's transcripts when
# a session ends.
#
# Thin shim per the hook-authoring guide: ALL logic lives in the ravel app
# package (`ravel::sync`), called via the `ravel-sync` blessed entrypoint.
# ravel-sync mirrors the harness's session `.jsonl` into
# `.ravel/transcripts/claude-code/` — the LOCAL BACKUP of the conversations,
# inside the soul repo dir (gitignored: transcripts are too big for GitHub)
# and out of the harness folder where they can be arbitrarily deleted — then
# ingests the mirror into `.ravel/oxigraph`. Both stages idempotent
# (turn-keyed): an end-of-session run costs seconds.
#
# Requires the ravel binaries (`cargo install --path .` in repolex-ai/ravel).
# Not installed → the hook no-ops silently (fail-soft; the next session with
# ravel installed catches everything up — the sync is incremental).

set -e

# --- kit-hook opt-out guard (managed; do not edit) ---
# A kit-managed hook can't be un-registered locally: CC merges hooks (local ADDS, never
# overrides) and kit-update re-converges settings.json every compaction. This guard is
# the escape hatch — list this hook's basename (no .sh) under soul.disabledHooks in
# .claude/settings.local.json and the hook no-ops. settings.local.json is gitignored and
# never touched by kit-update, so the opt-out is durable + soul-private. Fail-soft: any
# trouble reading/parsing → the hook runs normally (a broken opt-out never silences a hook).
# (Safe under `set -e`: a non-zero exit inside an `if` condition never triggers -e.)
_glx_local="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/settings.local.json"
if [ -f "$_glx_local" ] && grep -q disabledHooks "$_glx_local" 2>/dev/null; then
    _glx_self="$(basename "${BASH_SOURCE[0]:-$0}" .sh)"
    if python3 - "$_glx_local" "$_glx_self" <<'PY' 2>/dev/null
import json, sys
cfg, name = sys.argv[1], sys.argv[2]
try:
    with open(cfg) as f:
        disabled = (json.load(f).get("soul") or {}).get("disabledHooks") or []
    sys.exit(0 if name in disabled else 1)
except Exception:
    sys.exit(1)   # no file / bad json / no key → NOT disabled, run the hook
PY
    then
        exit 0
    fi
fi
# --- end kit-hook opt-out guard ---

HOOK_INPUT="$(cat 2>/dev/null || true)"

# Skip non-real ends (/clear, /resume) — same policy as SessionEnd-soul-save.
MATCHER="$(printf '%s' "$HOOK_INPUT" | python3 -c 'import sys,json
try:
    print(json.loads(sys.stdin.read() or "{}").get("matcher_value",""))
except Exception:
    pass' 2>/dev/null)"
case "$MATCHER" in
    clear|resume)
        exit 0
        ;;
esac

# Locate the blessed entrypoint; no ravel install → silent no-op.
RAVEL_SYNC="$(command -v ravel-sync || true)"
[ -z "$RAVEL_SYNC" ] && [ -x "$HOME/.cargo/bin/ravel-sync" ] && RAVEL_SYNC="$HOME/.cargo/bin/ravel-sync"
[ -z "$RAVEL_SYNC" ] && exit 0

"$RAVEL_SYNC" "${CLAUDE_PROJECT_DIR:-$PWD}" >/dev/null 2>&1 || true
exit 0
