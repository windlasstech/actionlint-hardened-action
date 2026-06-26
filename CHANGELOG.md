# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/2.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 12026-06-27

### Added

- Docker-based reusable GitHub Action wrapping `rhysd/actionlint` with explicit inputs (`paths`, `config-file`, `ignore`, `shellcheck`, `pyflakes`, `format`, `no-color`, `oneline`), including newline-separated shell-like glob handling that skips unmatched glob patterns, keeps `*`, `?`, and bracket expressions within a single path segment, and requires explicit leading-dot patterns for leading-dot names.
- SHA-pinned upstream image in `Dockerfile`: `rhysd/actionlint:1.7.12@sha256:b1934ee5f1c509618f2508e6eb47ee0d3520686341fec936f3b79331f9315667`.
- Dependabot configuration for Docker base image and GitHub Actions updates.
- Windlass security reusable workflows: Dependency Review, OSV Scanner (PR and full), and OpenSSF Scorecard.
- Self-test workflow exercising valid, invalid, unmatched glob, config-file, ignore, tool-disable, and formatting inputs.
- Test fixtures and bilingual documentation (`README.md` and `README.ko.md`).
- Initial project files: `LICENSE` and `README.md`.
- Repository conventions for agent-assisted development (`AGENTS.md`).
- Standard OS-specific `.gitignore` rules.
- Korean README translation (`README.ko.md`).

[unreleased]: https://github.com/windlasstech/actionlint-hardened-action/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/windlasstech/actionlint-hardened-action/releases/tag/v1.0.0
