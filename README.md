# git-lex-kit-ravel

The [ravel](https://github.com/repolex-ai/ravel) transcript-graph engine's
git-lex kit. Opt-in: `git lex kit-add repolex-ai/git-lex-kit-ravel`.

What a soul gets:

- **The ravel ontology** (`.lex/ontology/ravel/ravel.ttl`) — vocabulary for
  conversational turns + the reader-annotation layer. Graph-only: no folders
  are scaffolded in the soul corpus.
- **`SessionEnd-ravel-ravelsync.sh`** — on every real session end, mirrors the
  harness's session `.jsonl` into `.ravel/_ignore/transcripts/claude-code/`
  (the local transcript backup, out of the harness's deletable folder) and
  ingests the mirror into `.ravel/_ignore/oxigraph`. Both stages idempotent;
  requires the `ravel` binaries (`cargo install --path .` in the ravel repo).
  Without them the hook no-ops silently.

Layout follows the stack-wide `_ignore/` pocket law (Rob, 2026-08-05):
`.ravel/_ignore/` is machine-local and gitignored; everything else in
`.ravel/` (e.g. future `config/`) is committable. `ravel-sync` self-migrates
pre-pocket installs (loud log; refuses an ambiguous dual layout).

> **Note:** git-lex's managed gitignore block covers `.ravel/` (whole-dir on
> pre-pocket layouts, narrowing to `.ravel/_ignore/` once the legacy paths are
> gone — the emitter is layout-aware per-repo). `git lex kit-update` converges
> the entry automatically. On an older git-lex binary, add `.ravel/_ignore/`
> to `.gitignore` by hand before your first save, or it will commit the whole
> store + transcript mirror (th34's 82fe1d7 — the receipt that got the fix
> shipped same-day).

Ontology source of truth: the ravel app repo (`ontology/ravel/ravel.ttl`),
published here by `subtexture/tools/ontology-publish`. Edit there, never here.
