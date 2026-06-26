<div align="center">

# actionlint-hardened-action

![GitHub License](https://img.shields.io/github/license/windlasstech/actionlint-hardened-action)
[![SemVer Versioning](https://img.shields.io/badge/version_scheme-SemVer-0097a7)](#versioning)
[![GitHub Release](https://img.shields.io/github/v/release/windlasstech/actionlint-hardened-action)](https://github.com/windlasstech/actionlint-hardened-action/releases)
[![GitHub Release Date](https://img.shields.io/github/release-date/windlasstech/actionlint-hardened-action)](https://github.com/windlasstech/actionlint-hardened-action/releases)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-3.0-4baaaa.svg)](https://github.com/windlasstech/.github/blob/main/CODE_OF_CONDUCT.md)
[![GitHub issues](https://img.shields.io/badge/issue_tracking-GitHub-blue.svg)](https://github.com/windlasstech/actionlint-hardened-action/issues)

[![actionlint-hardened self-test](https://github.com/windlasstech/actionlint-hardened-action/actions/workflows/actionlint-self-test.yml/badge.svg)](https://github.com/windlasstech/actionlint-hardened-action/actions/workflows/actionlint-self-test.yml)
[![OSV Scanner Full](https://github.com/windlasstech/actionlint-hardened-action/actions/workflows/osv-scanner-full.yml/badge.svg)](https://github.com/windlasstech/actionlint-hardened-action/actions/workflows/osv-scanner-full.yml)
[![Dependency Review](https://github.com/windlasstech/actionlint-hardened-action/actions/workflows/dependency-review.yml/badge.svg)](https://github.com/windlasstech/actionlint-hardened-action/actions/workflows/dependency-review.yml)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/windlasstech/actionlint-hardened-action/badge)](https://scorecard.dev/viewer/?uri=github.com/windlasstech/actionlint-hardened-action)

English | [한국어](README.ko.md)

</div>

Docker-based GitHub Action for running [actionlint](https://github.com/rhysd/actionlint) with SHA-pinned images and Dependabot-managed updates. A hardened, reusable wrapper for Windlass workflows and the broader community.

## Why this wrapper?

[The official actionlint usage examples](https://github.com/rhysd/actionlint/blob/v1.7.12/docs/usage.md#use-actionlint-on-github-actions) rely on downloading a raw install script from the upstream default branch. [This is vulnerable from a supply-chain security perspective](https://www.stepsecurity.io/blog/pinning-github-actions-for-enhanced-security-a-complete-guide), and this wrapper action provides [a safer alternative to inline scripts](https://www.stepsecurity.io/blog/github-actions-security-best-practices#avoid-inline-scripts). For supply-chain hardening, this action instead:

- Runs actionlint from a Docker image pinned by both tag **and** SHA256 digest.
- Lets Dependabot propose updates when the upstream image changes.
- [Keeps workflow permissions minimal](https://github.com/windlasstech/.github/blob/main/docs/security/workflow-hardening.md#permission-management) and integrates with [Windlass security scanning workflows](https://github.com/windlasstech/.github#cicd-workflows).

## Usage

```yaml
- uses: actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 # v7.0.0
  with:
    persist-credentials: false

- uses: windlasstech/actionlint-hardened-action@v1
```

For reproducible builds, pin to a full commit SHA:

```yaml
- uses: actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 # v7.0.0
  with:
    persist-credentials: false

- uses: windlasstech/actionlint-hardened-action@<sha>
```

Run actionlint against specific workflow files or glob patterns:

```yaml
- uses: actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 # v7.0.0
  with:
    persist-credentials: false

- uses: windlasstech/actionlint-hardened-action@v1
  with:
    paths: |
      .github/workflows/*.yml
      .github/workflows/*.yaml
```

Use a custom config file:

```yaml
- uses: actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 # v7.0.0
  with:
    persist-credentials: false

- uses: windlasstech/actionlint-hardened-action@v1
  with:
    config-file: .github/actionlint.yaml
```

Disable optional integrations:

```yaml
- uses: actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 # v7.0.0
  with:
    persist-credentials: false

- uses: windlasstech/actionlint-hardened-action@v1
  with:
    shellcheck: ""
    pyflakes: ""
```

## Inputs

| Input         | Description                                                                                                                                                                                           | Required | Default      |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------ |
| `paths`       | Newline-separated list of workflow files or glob patterns to lint. Empty lets actionlint auto-discover workflows. Directory inputs are passed through to actionlint and fail the same way as the CLI. | No       | `''`         |
| `config-file` | Path to an actionlint config file.                                                                                                                                                                    | No       | `''`         |
| `ignore`      | Newline-separated list of RE2 patterns passed as repeatable `-ignore` flags.                                                                                                                          | No       | `''`         |
| `shellcheck`  | Path or command for ShellCheck integration. Passing an explicit empty string disables it.                                                                                                             | No       | `shellcheck` |
| `pyflakes`    | Path or command for Pyflakes integration. Passing an explicit empty string disables it.                                                                                                               | No       | `pyflakes`   |
| `format`      | Go template string passed to `-format`.                                                                                                                                                               | No       | `''`         |
| `no-color`    | Disable ANSI color codes in output.                                                                                                                                                                   | No       | `true`       |
| `oneline`     | Print one error per line.                                                                                                                                                                             | No       | `false`      |

### Glob patterns

The `paths` input accepts one file path or glob pattern per line. Glob matching is shell-like for the supported pattern syntax, but the input is not evaluated by a shell.

- Supported metacharacters: `*`, `?`, and bracket expressions such as `[ab]` or `[a-z]`.
- `*`, `?`, and bracket expressions match within a single path segment only; they do not cross `/`.
- Files or directories whose names start with `.` are matched only by pattern segments that also start with `.`.
- Unmatched glob patterns are skipped.
- Shell syntax such as quotes, brace expansion (`*.{yml,yaml}`), extglob, command substitution, and recursive globstar (`**`) is not supported.

Brace expansion and recursive globstar are intentionally unsupported to keep `paths` matching predictable and safe. Brace expansion is a shell expansion feature rather than path matching; use multiple lines instead, for example `*.yml` and `*.yaml`. Recursive globstar semantics vary across shells and settings, so supporting `**` would make it harder to promise shell-like behavior and could include more files than intended.

## Exit codes

actionlint returns the following exit codes:

| Code | Meaning                                  |
| ---- | ---------------------------------------- |
| `0`  | No lint problems found.                  |
| `1`  | Lint problems found.                     |
| `2`  | Invalid command-line usage.              |
| `3`  | Fatal error (e.g. unable to read files). |

If an input value is invalid (for example, `no-color: maybe`), the wrapper exits with code `2` and prints a clear error message.

## Config file

actionlint reads `.github/actionlint.yaml` or `.github/actionlint.yml` automatically. You can also point to a custom config file with the `config-file` input.

## Security

- The upstream image is [pinned by tag and SHA256 digest](https://github.com/windlasstech/.github/blob/main/docs/security/workflow-hardening.md#action-references) in `Dockerfile`.
- Dependabot is configured to update the Docker base image and external GitHub Actions.
- This repository uses [Windlass reusable workflows](https://github.com/windlasstech/.github#cicd-workflows) for OpenSSF Scorecard, OSV Scanner, and Dependency Review.
- Caller workflows should use [the minimum required permissions](https://github.com/windlasstech/.github/blob/main/docs/security/workflow-hardening.md#permission-management), typically `contents: read`.

## Versioning

This action uses its own [Semantic Versioning](https://semver.org/) independent of the upstream actionlint version. Release notes clearly state the embedded actionlint version, for example: `v1.0.0 - includes actionlint v1.7.12`.

## License

See [LICENSE](./LICENSE).
