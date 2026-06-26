# SHELL FORMATTING TOOLING KNOWLEDGE BASE

**Generated:** 12026-06-27
**Commit:** 2e5bd25
**Branch:** release/v1.0.0

## OVERVIEW

Separate Go module that pins `mvdan.cc/sh/v3/cmd/shfmt` for consistent shell script formatting.

## STRUCTURE

```text
tools/
├── go.mod           # Module definition: pins `mvdan.cc/sh/v3`
├── go.sum           # Dependency checksums
├── run-shfmt.sh     # Wrapper to format or check shell files
└── tools.go         # `//go:build tools` import for `go run`
```

## WHERE TO LOOK

| Task                    | Location                            | Notes                                         |
| ----------------------- | ----------------------------------- | --------------------------------------------- |
| Run shfmt in check mode | `tools/run-shfmt.sh --check <path>` | Exits non-zero on diff; used in CI            |
| Run shfmt in write mode | `tools/run-shfmt.sh <path>`         | Reformats files in place                      |
| Pin shfmt version       | `tools/go.mod`                      | Update `mvdan.cc/sh/v3` and run `go mod tidy` |

## CONVENTIONS

- shfmt runs with `-i 0 -ci` (tabs for indentation, switch-case indentation).
- Paths may be absolute or relative; relative paths are resolved from repo root.
- The wrapper accepts `--check` as the first argument and treats all remaining arguments as file paths.
- No paths means no work (exit 0), so callers must pass the files they want formatted.

## COMMANDS

```bash
# Format entrypoint.sh and scripts
sh tools/run-shfmt.sh entrypoint.sh scripts/*.sh tools/*.sh

# Check formatting without writing
sh tools/run-shfmt.sh --check entrypoint.sh scripts/*.sh tools/*.sh
```

## ANTI-PATTERNS

- Do **not** run `go run mvdan.cc/sh/v3/cmd/shfmt` outside `tools/`; use the pinned module via `run-shfmt.sh`.
- Do **not** pass directories to the wrapper; it expects file paths.
- Do **not** change indentation style; keep `-i 0` (tabs) to match the rest of the repo.
