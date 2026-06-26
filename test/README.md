# Test Fixtures

This directory contains fixed test inputs (fixtures) for the `actionlint-hardened-action` self-test workflow. They define the behavioral contract of the wrapper action before any production code is implemented.

## Why fixtures?

The fixtures follow a test-driven approach: the expected behavior is captured first, and the wrapper implementation is then verified against these fixtures. This makes it possible to run the local action (`uses: ./`) in a GitHub Actions workflow and assert specific outcomes for each scenario.

## Fixture layout

```text
test/
└── fixtures/
    ├── valid/
    │   └── .github/workflows/valid.yml
    ├── invalid/
    │   └── .github/workflows/invalid.yml
    ├── config/
    │   ├── .github/workflows/ignored.yml
    │   └── .github/actionlint.yaml
    └── dash-leading/
        └── .github/workflows/valid.yml
```

## Fixtures

### `valid/.github/workflows/valid.yml`

A minimal, syntactically valid GitHub Actions workflow.

- **Purpose**: Verify the happy path.
- **Expected outcome**: `actionlint` exits `0` with no findings.
- **Paths input behavior**: Used for single-file, glob, unmatched glob, multiline `paths`, and empty auto-discovery self-test scenarios.
- **Directory input behavior**: Passing `test/fixtures/valid/.github/workflows` as a directory is expected to fail the same way as the `actionlint` CLI.

### `invalid/.github/workflows/invalid.yml`

A workflow that contains a structural error.

- **Purpose**: Verify the failure path.
- **Expected outcome**: `actionlint` exits `1` because of the unknown `foo` key at the workflow level.
- **Known error**: `unexpected key "foo" for "workflow" section`.
- **Output behavior**: Used to assert the exact `format`, `no-color`, and `oneline` output produced by the wrapper.

### `config/.github/workflows/ignored.yml`

A workflow that contains an error matching the ignore rule in the paired config file.

- **Purpose**: Verify the `config-file` input and the `ignore` input.
- **Expected outcome**:
  - Without config: `actionlint` exits `1`.
  - With `config-file: test/fixtures/config/.github/actionlint.yaml`: `actionlint` exits `0`.
  - With `ignore: 'unexpected key "foo" for "workflow" section.*'`: `actionlint` exits `0`.

### `config/.github/actionlint.yaml`

The actionlint configuration file paired with `ignored.yml`.

- **Purpose**: Suppress the known error in `ignored.yml` so the config-file scenario passes.
- **Rule**: ignores errors matching `unexpected key "foo" for "workflow" section`.

### `dash-leading/.github/workflows/valid.yml`

A minimal valid workflow file used to create a runtime copy named `-dash-leading-valid.yml`.

- **Purpose**: Verify that `paths` entries starting with `-` are passed after an option separator and cannot be interpreted as `actionlint` flags.
- **Expected outcome**: `actionlint` exits `0` with no findings.

## How they are used

The self-test workflow at `.github/workflows/actionlint-self-test.yml` runs the local action against each fixture and asserts the expected outcome. This ensures that:

- Required inputs map correctly to `actionlint` CLI arguments, including single-file, glob, unmatched glob, multiline, empty auto-discovery, dash-leading, and CLI-equivalent directory failure scenarios.
- Optional inputs such as `config-file`, `ignore`, `shellcheck`, and `pyflakes` behave as documented, including a fake ShellCheck command that proves empty-string ShellCheck disabling.
- Output-shaping inputs such as `format`, `no-color`, and `oneline` produce the expected rendered text without ANSI escape sequences, with `oneline` asserted independently from custom `format`.
- The wrapper exits with the same code as the underlying `actionlint` process.

## Adding new fixtures

When adding a new fixture:

1. Place it under the appropriate subdirectory.
2. Document its purpose and expected outcome in this file.
3. Add a corresponding step to `.github/workflows/actionlint-self-test.yml`.
4. Verify the fixture locally with the `actionlint` CLI before committing.
