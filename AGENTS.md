## Repo Conventions

- **Dates in documents**: Use Holocene Era / Human Era year format (e.g., `12026-06-23`).
- **Bilingual README updates**: When editing any `README.md`, update the corresponding `README.ko.md` in the same directory as part of the same change.

## Commits

- **DCO sign-off required**: Every commit must include a `Signed-off-by:` line. Use `git commit -s` (or `git commit --signoff`) for all commits. Lefthook enforces this in the commit-msg hook.

## Changelog Management

- Maintain `CHANGELOG.md` according to [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/), but use the organization's Human Era date convention for release headings (for example, `## [0.1.0] - 12026-06-13`).
- Changelog entries are for users and downstream integrators. Summarize notable upgrade-relevant behavior; do not generate changelog entries by dumping commit logs.
- For every PR, complete the organization PR template's `Changelog` section with:
  - **Category**: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`, or `None`
  - **User-facing note**: a short impact summary, or why no note is needed
- Use `None` for changes with no direct user-facing impact, such as test cleanup, internal refactoring, formatting, or CI-only maintenance.
- During development, update only the `[Unreleased]` section when a PR has user-facing impact. Group entries by `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, and `Security`; do not create empty category sections.
- For release PRs, move `[Unreleased]` entries into the new version section, recreate an empty `[Unreleased]` section at the top, update comparison links at the bottom of `CHANGELOG.md`, and use the finalized version section as the GitHub Release body.

## CI / Security

- Reusable workflows from `windlasstech/.github`:
  - Scorecard supply-chain security
  - OSV Scanner (full scan on schedule + push to main; PR scan on PRs + merge groups)
  - Dependency Review (on PRs + merge groups)
- Do not add build/test CI that bypasses these security checks.
- **Always reference** `windlasstech/.github` main branch security docs before making security-relevant changes:
  - Primary security policy: <https://raw.githubusercontent.com/windlasstech/.github/refs/heads/main/SECURITY.md>
  - Dependency security: <https://raw.githubusercontent.com/windlasstech/.github/refs/heads/main/docs/security/dependency-security.md>
  - SLSA compliance framework: <https://raw.githubusercontent.com/windlasstech/.github/refs/heads/main/docs/security/slsa-compliance-framework.md>
  - Workflow hardening: <https://raw.githubusercontent.com/windlasstech/.github/refs/heads/main/docs/security/workflow-hardening.md>
- Supply-chain baseline from the organization policy:
  - SLSA Build L1/L2 are required; Build L3+ is the target wherever feasible.
  - SLSA Source L1/L2 are required; Source L3 controls are followed where feasible; Source L4 is structurally blocked for a 1-person organization.
  - Release source integrity uses GPG-signed annotated tags, GPG-signed commits on `main`, protected branches/tags, linear history, and required CI gates.
  - Released binaries and container images must include signed SPDX and CycloneDX SBOM attestations when the build can generate them; public releases should publish the same SBOM files as release assets when possible.
  - Registry-published release artifacts should upload linked artifacts storage metadata with `artifact-metadata: write` when supported.
  - Dependency security is layered: committed lockfiles, Dependabot, cooldowns, Dependency Review, and OSV Scanner. Security updates bypass cooldowns; normal version updates use cooldowns.
  - Workflow hardening requires SHA-pinned third-party actions, hardened runners, explicit minimal top-level permissions, job-level elevation only when required, OIDC instead of long-lived cloud credentials, and protected production environments.
- GitHub Actions permission reminders:
  - Artifact attestations with `actions/attest`: `contents: read`, `id-token: write`, `attestations: write`.
  - Linked artifacts storage records: add `artifact-metadata: write` and use registry artifact subjects by immutable digest.
  - Container registry pushes: add `packages: write` only on the job that pushes images.
  - Release asset upload: add `contents: write` only on the release job.
  - PR comments: add `pull-requests: write` only for jobs that write comments.

## Pull Requests

- PRs must follow the template defined in `windlasstech/.github`:
  - <https://raw.githubusercontent.com/windlasstech/.github/refs/heads/main/.github/PULL_REQUEST_TEMPLATE.md>
- **Always fetch the template content** and write the PR body to match it. Do not rely on `gh pr create` to auto-populate the template; if it does not, manually compose the body using the fetched template structure.
