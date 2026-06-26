# RELEASE AUTOMATION KNOWLEDGE BASE

**Generated:** 12026-06-27
**Commit:** da623b2
**Branch:** release/v1.0.0

## OVERVIEW

GPG-signed annotated tag creation and its shell-based regression test harness.

## STRUCTURE

```text
scripts/
├── create-release-tag.sh       # Interactive release tag helper
└── test-create-release-tag.sh  # Fake-git fixture harness
```

## WHERE TO LOOK

| Task | Location | Notes |
|---|---|---|
| Create a release tag | `create-release-tag.sh` | Requires `user.signingkey` and a matching `CHANGELOG.md` section |
| Add a release-tag test case | `test-create-release-tag.sh` | Append a `test_*` function and register it in `main()` |
| Fake git behavior | `test-create-release-tag.sh` (`make_repo`) | Injected `bin/git` intercepts `config --get user.signingkey` and `tag -s -a -F` |

## CONVENTIONS

- Version arguments may be plain (`1.0.0`) or already prefixed (`v1.0.0`); the script normalizes to `v` tags.
- Tags are signed annotated tags (`git tag -s -a`) using the annotation body extracted from `CHANGELOG.md`.
- Annotation extraction stops at the next `## [` heading or link-reference block (`[...]: ...`).
- Empty release sections and missing changelog sections are treated as fatal errors.

## ANTI-PATTERNS

- Do **not** create lightweight or unsigned tags for releases.
- Do **not** allow the script to run without an interactive confirmation (`y`/`n`/`e`).
- Do **not** edit the fake `git` interceptor without updating its recorded-tag assertions.

## COMMANDS

```bash
# Run release-tag helper (requires GPG signing key)
sh scripts/create-release-tag.sh 1.0.1

# Run release-tag tests locally
sh scripts/test-create-release-tag.sh
```
