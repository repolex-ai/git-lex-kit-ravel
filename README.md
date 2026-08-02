# git-lex-kit-ravel

The [ravel](https://github.com/repolex-ai/ravel) transcript-graph engine's
git-lex kit. Opt-in: `git lex kit-add repolex-ai/git-lex-kit-ravel`.

What a soul gets:

- **The ravel ontology** (`.lex/ontology/ravel/ravel.ttl`) — vocabulary for
  conversational turns + the reader-annotation layer. Graph-only: no folders
  are scaffolded in the soul corpus.
- **`SessionEnd-ravel-ravelsync.sh`** — on every real session end, mirrors the
  harness's session `.jsonl` into `.ravel/transcripts/claude-code/` (the local
  transcript backup, out of the harness's deletable folder) and ingests the
  mirror into `.ravel/oxigraph`. Both stages idempotent; requires the `ravel`
  binaries (`cargo install --path .` in the ravel repo). Without them the hook
  no-ops silently.

Ontology source of truth: the ravel app repo (`ontology/ravel/ravel.ttl`),
published here by `subtexture/tools/ontology-publish`. Edit there, never here.
