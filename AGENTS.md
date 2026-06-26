# PROJECT KNOWLEDGE BASE

**Generated:** 12026-06-27
**Commit:** 2e5bd25
**Branch:** release/v1.0.0

## OVERVIEW

Docker-based reusable GitHub Action that wraps `rhysd/actionlint` with a SHA-pinned image, Dependabot-managed updates, and hardened Windlass security workflows.

## STRUCTURE

```text
.
├── action.yml              # Action metadata and inputs
├── Dockerfile              # SHA-pinned upstream actionlint image
├── entrypoint.sh           # Runtime wrapper: input normalization, glob handling, CLI invocation
├── scripts/                # Release automation and its shell-based test harness
├── test/                   # Self-test fixtures and fixture documentation
├── tools/                  # Go module pinning shfmt for shell formatting
├── .github/workflows/      # CI: self-test, Scorecard, OSV Scanner, Dependency Review
├── .github/dependabot.yml  # Docker base image + GitHub Actions update checks
├── CHANGELOG.md            # Keep a Changelog, Human Era dates
├── README.md / README.ko.md
└── AGENTS.md               # This file
```

## WHERE TO LOOK

| Task                          | Location                             | Notes                                                                 |
| ----------------------------- | ------------------------------------ | --------------------------------------------------------------------- |
| Change action inputs          | `action.yml`                         | Also update `README.md` / `README.ko.md` input tables                 |
| Update actionlint version     | `Dockerfile`                         | Pin tag **and** SHA256 digest; Dependabot will propose future updates |
| Change CLI wrapping logic     | `entrypoint.sh`                      | Handles bool normalization, glob matching, tool disable flags         |
| Add/modify self-test fixtures | `test/fixtures/`                     | Document in `test/README.md` and add workflow step                    |
| Run release tagging           | `scripts/create-release-tag.sh`      | Requires GPG signing key and CHANGELOG.md section                     |
| Release script tests          | `scripts/test-create-release-tag.sh` | Pure shell harness using fake `git` binary                            |
| Format shell scripts          | `tools/run-shfmt.sh`                 | Pins `mvdan.cc/sh/v3` via the `tools/` Go module                      |

## CODE MAP

| Symbol                                                | Type         | Location                             | Role                                                      |
| ----------------------------------------------------- | ------------ | ------------------------------------ | --------------------------------------------------------- |
| `normalize_bool`                                      | function     | `entrypoint.sh:4`                    | Validates `true`/`false` inputs, exits 2 on invalid       |
| `has_glob` / `match_path_segment` / `glob_match_path` | functions    | `entrypoint.sh:22`                   | Shell-like glob matching limited to a single path segment |
| `create-release-tag.sh`                               | script       | `scripts/create-release-tag.sh`      | Creates signed annotated tags from CHANGELOG sections     |
| `test-create-release-tag.sh`                          | test harness | `scripts/test-create-release-tag.sh` | Fixture-based shell tests for release script              |

## CONVENTIONS

- **Dates in documents**: Use Holocene Era / Human Era year format (e.g., `12026-06-23`).
- **Bilingual README updates**: When editing any `README.md`, update the corresponding `README.ko.md` in the same directory as part of the same change.
- **Commits**: DCO sign-off required. Use `git commit -s` for all commits; Lefthook enforces this in the commit-msg hook.
- **Formatting**: Prettier, markdownlint, and shfmt run via Lefthook pre-commit. Shell scripts use tabs (`shfmt -i 0 -ci`); Markdown and YAML are 2-space indented.
- **Changelog**: Keep a Changelog 2.0.0 with Human Era release headings. Group `[Unreleased]` entries by category; no empty sections. Release PRs move entries into the new version section and recreate `[Unreleased]`.
- **PR template**: Fetch the template from `windlasstech/.github` and compose the PR body to match it; do not rely on `gh pr create` to auto-populate it.

### Changelog Management

- Maintain `CHANGELOG.md` according to [Keep a Changelog 2.0.0](https://keepachangelog.com/en/2.0.0/), but use the organization's Human Era date convention for release headings (for example, `## [0.1.0] - 12026-06-13`).
- Changelog entries are for users and downstream integrators. Summarize notable upgrade-relevant behavior; do not generate changelog entries by dumping commit logs.
- For every PR, complete the organization PR template's `Changelog` section with:
  - **Category**: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`, or `None`
  - **User-facing note**: a short impact summary, or why no note is needed
- Use `None` for changes with no direct user-facing impact, such as test cleanup, internal refactoring, formatting, or CI-only maintenance.
- During development, update only the `[Unreleased]` section when a PR has user-facing impact. Group entries by `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, and `Security`; do not create empty category sections.
- For release PRs, move `[Unreleased]` entries into the new version section, recreate an empty `[Unreleased]` section at the top, update comparison links at the bottom of `CHANGELOG.md`, and use the finalized version section as the GitHub Release body.

## ANTI-PATTERNS (THIS PROJECT)

- Do **not** add build/test CI that bypasses the reusable security workflows from `windlasstech/.github`.
- Do **not** rely on `gh pr create` to auto-populate the PR template.
- Do **not** leave `[Unreleased]` changelog categories empty.
- Do **not** update a `README.md` without its matching `README.ko.md`.

## UNIQUE STYLES

- Runtime inputs with hyphens (`config-file`, `no-color`) are read via both `printenv 'INPUT_X-Y'` and the underscore fallback because GitHub Actions sets env vars with underscores.
- `paths` input implements its own shell-like glob parser instead of shell expansion to avoid brace expansion, globstar, and command-substitution risks.
- Paths starting with `-` are passed after `--` so they are never interpreted as actionlint flags.

## COMMANDS

```bash
# Run release-tag helper (requires GPG signing key)
sh scripts/create-release-tag.sh 1.0.1

# Run release-tag tests locally
sh scripts/test-create-release-tag.sh

# Format shell scripts
sh tools/run-shfmt.sh entrypoint.sh scripts/*.sh tools/*.sh

# Check shell formatting without writing
sh tools/run-shfmt.sh --check entrypoint.sh scripts/*.sh tools/*.sh

# Lint shell scripts (if shellcheck is available)
shellcheck entrypoint.sh scripts/*.sh tools/*.sh

# Build the Docker image locally
docker build -t actionlint-hardened-action .
```

## NOTES

- Upstream image is pinned by tag **and** SHA256 digest in `Dockerfile`.
- Caller workflows should use minimal permissions, typically `contents: read`.
- Security docs live in `windlasstech/.github` main branch; reference them before any security-relevant change:
  - Security policy: <https://raw.githubusercontent.com/windlasstech/.github/refs/heads/main/SECURITY.md>
  - Dependency security: <https://raw.githubusercontent.com/windlasstech/.github/refs/heads/main/docs/security/dependency-security.md>
  - SLSA compliance: <https://raw.githubusercontent.com/windlasstech/.github/refs/heads/main/docs/security/slsa-compliance-framework.md>
  - Workflow hardening: <https://raw.githubusercontent.com/windlasstech/.github/refs/heads/main/docs/security/workflow-hardening.md>
- PRs must follow the template defined in `windlasstech/.github`:
  - <https://raw.githubusercontent.com/windlasstech/.github/refs/heads/main/.github/PULL_REQUEST_TEMPLATE.md>
  - **Always fetch the template content** and write the PR body to match it. Do not rely on `gh pr create` to auto-populate the template; if it does not, manually compose the body using the fetched template structure.
- Release source integrity requires GPG-signed annotated tags and GPG-signed commits on `main`.
