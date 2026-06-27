<div align="center">

# actionlint-hardened-action

![GitHub License](https://img.shields.io/github/license/windlasstech/actionlint-hardened-action)
[![SemVer Versioning](https://img.shields.io/badge/version_scheme-SemVer-0097a7)](#버전-관리)
[![GitHub Release](https://img.shields.io/github/v/release/windlasstech/actionlint-hardened-action)](https://github.com/windlasstech/actionlint-hardened-action/releases)
[![GitHub Release Date](https://img.shields.io/github/release-date/windlasstech/actionlint-hardened-action)](https://github.com/windlasstech/actionlint-hardened-action/releases)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-3.0-4baaaa.svg)](https://github.com/windlasstech/.github/blob/main/CODE_OF_CONDUCT.md)
[![GitHub issues](https://img.shields.io/badge/issue_tracking-GitHub-blue.svg)](https://github.com/windlasstech/actionlint-hardened-action/issues)

[![actionlint-hardened self-test](https://github.com/windlasstech/actionlint-hardened-action/actions/workflows/actionlint-self-test.yml/badge.svg)](https://github.com/windlasstech/actionlint-hardened-action/actions/workflows/actionlint-self-test.yml)
[![Lint](https://github.com/windlasstech/actionlint-hardened-action/actions/workflows/lint.yml/badge.svg)](https://github.com/windlasstech/actionlint-hardened-action/actions/workflows/lint.yml)
[![CodeQL](https://github.com/windlasstech/actionlint-hardened-action/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/windlasstech/actionlint-hardened-action/actions/workflows/github-code-scanning/codeql)
[![OSV Scanner Full](https://github.com/windlasstech/actionlint-hardened-action/actions/workflows/osv-scanner-full.yml/badge.svg)](https://github.com/windlasstech/actionlint-hardened-action/actions/workflows/osv-scanner-full.yml)
[![Dependency Review](https://github.com/windlasstech/actionlint-hardened-action/actions/workflows/dependency-review.yml/badge.svg)](https://github.com/windlasstech/actionlint-hardened-action/actions/workflows/dependency-review.yml)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/windlasstech/actionlint-hardened-action/badge)](https://scorecard.dev/viewer/?uri=github.com/windlasstech/actionlint-hardened-action)

[English](README.md) | 한국어

</div>

Dependabot을 통해 업스트림에 맞춰 업데이트하는, SHA-pinned 이미지 기반으로 [actionlint](https://github.com/rhysd/actionlint)를 실행하는 Docker 기반 GitHub Action입니다. Windlass 조직 워크플로우 및 커뮤니티 생태계를 위한, 보안 강화한 재사용 가능 래퍼입니다.

## 이 래퍼를 사용하는 이유

[공식 actionlint 사용 예시](https://github.com/rhysd/actionlint/blob/v1.7.12/docs/usage.md#use-actionlint-on-github-actions)는 업스트림 기본 브랜치에서 raw 설치 스크립트를 내려받는 방식에 의존합니다. [이는 공급망 보안 측면에서 취약한 동작이며](https://www.stepsecurity.io/blog/pinning-github-actions-for-enhanced-security-a-complete-guide), 이 wrapper 액션은 [인라인 스크립트보다 더 안전한 대안](https://www.stepsecurity.io/blog/github-actions-security-best-practices#avoid-inline-scripts)을 제공합니다. 이 action은 공급망 보안을 위해 다음과 같이 동작하고 유지관리됩니다.

- tag와 SHA256 digest **둘 모두**로 고정된 Docker 이미지에서 actionlint를 실행합니다.
- 업스트림 이미지가 변경되면 Dependabot이 자동으로 업데이트 PR을 제안합니다.
- [워크플로우 권한을 최소화](https://github.com/windlasstech/.github/blob/main/docs/security/workflow-hardening.md#permission-management)하고 [Windlass 보안 스캔 워크플로우](https://github.com/windlasstech/.github#cicd-workflows)와 통합합니다.

> [!NOTE]
> 이 action은 [Docker container action](https://docs.github.com/ko/actions/tutorials/use-containerized-services/create-a-docker-container-action)이므로 GitHub Actions가 내부적으로 컨테이너를 빌드 및 실행합니다. GitHub-hosted runner에서 이 action을 사용하는 워크플로우 사용자는 Docker를 설치하거나, Docker daemon을 시작하거나, 별도의 Docker setup step을 추가할 필요가 **없습니다**.

## 사용법

```yaml
- uses: actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 # v7.0.0
  with:
    persist-credentials: false

- uses: windlasstech/actionlint-hardened-action@v1
```

재현 가능한 빌드를 위해 전체 커밋 SHA로 고정할 수 있습니다(선택사항이지만, **권장합니다**).

```yaml
- uses: actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 # v7.0.0
  with:
    persist-credentials: false

- uses: windlasstech/actionlint-hardened-action@043a16f2538fe7bee89d8e19bbd5292e925210e0 # v1.0.0
```

특정 workflow 파일 또는 glob 패턴에 대해 actionlint를 실행할 수 있습니다.

```yaml
- uses: actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 # v7.0.0
  with:
    persist-credentials: false

- uses: windlasstech/actionlint-hardened-action@043a16f2538fe7bee89d8e19bbd5292e925210e0 # v1.0.0
  with:
    paths: |
      .github/workflows/*.yml
      .github/workflows/*.yaml
```

사용자 정의 config 파일을 사용할 수 있습니다.

```yaml
- uses: actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 # v7.0.0
  with:
    persist-credentials: false

- uses: windlasstech/actionlint-hardened-action@043a16f2538fe7bee89d8e19bbd5292e925210e0 # v1.0.0
  with:
    config-file: .github/actionlint.yaml
```

통합 옵션을 비활성화할 수 있습니다.

```yaml
- uses: actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 # v7.0.0
  with:
    persist-credentials: false

- uses: windlasstech/actionlint-hardened-action@043a16f2538fe7bee89d8e19bbd5292e925210e0 # v1.0.0
  with:
    shellcheck: ""
    pyflakes: ""
```

## Inputs

| Input         | 설명                                                                                                                                                                                     | 필수   | 기본값       |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | ------------ |
| `paths`       | lint할 workflow 파일 또는 glob 패턴의 줄 단위 목록입니다. 비어 있으면 actionlint가 workflow를 자동으로 찾습니다. 디렉터리 입력은 actionlint에 그대로 전달되어 CLI와 동일하게 실패합니다. | 아니오 | `''`         |
| `config-file` | actionlint config 파일 경로입니다.                                                                                                                                                       | 아니오 | `''`         |
| `ignore`      | 반복 가능한 `-ignore` 플래그로 전달되는, RE2 패턴의 줄 단위 목록입니다.                                                                                                                  | 아니오 | `''`         |
| `shellcheck`  | ShellCheck 통합용 경로 또는 명령입니다. 빈 문자열을 명시적으로 전달 시 비활성화됩니다.                                                                                                   | 아니오 | `shellcheck` |
| `pyflakes`    | Pyflakes 통합용 경로 또는 명령입니다. 빈 문자열을 명시적으로 전달 시 비활성화됩니다.                                                                                                     | 아니오 | `pyflakes`   |
| `format`      | `-format`에 전달될 Go template 문자열입니다.                                                                                                                                             | 아니오 | `''`         |
| `no-color`    | 출력에서 ANSI 색상 코드를 비활성화합니다.                                                                                                                                                | 아니오 | `true`       |
| `oneline`     | 오류를 한 줄씩 출력합니다.                                                                                                                                                               | 아니오 | `false`      |

### Glob 패턴

`paths` 입력은 줄마다 하나의 파일 경로 또는 glob 패턴을 받습니다. Glob 매칭은 지원하는 패턴 문법에 대해 shell과 유사하게 동작하지만, 입력값을 shell로 평가하지는 않습니다.

- 지원하는 메타문자: `*`, `?`, `[ab]` 또는 `[a-z]` 같은 bracket expression.
- `*`, `?`, bracket expression은 단일 path segment 안에서만 매칭되며 `/`를 넘어가지 않습니다.
- 이름이 `.`로 시작하는 파일 또는 디렉터리는 패턴 segment도 `.`로 시작할 때만 매칭됩니다.
- 매칭되지 않는 glob 패턴은 건너뜁니다.
- quote, brace expansion(`*.{yml,yaml}`), extglob, command substitution, recursive globstar(`**`) 같은 shell 문법은 지원하지 않습니다.

Brace expansion과 recursive globstar는 `paths` 매칭을 예측 가능하고 안전하게 유지하기 위해 의도적으로 지원하지 않습니다. Brace expansion은 path matching이 아니라 shell expansion 기능이므로, `*.yml`과 `*.yaml`처럼 여러 줄로 나누어 작성하세요. Recursive globstar의 의미는 shell과 설정에 따라 달라지므로 `**`를 지원하면 shell-like 동작을 명확히 보장하기 어렵고 의도보다 많은 파일이 포함될 수 있습니다.

## Exit codes

actionlint는 다음 exit code를 반환합니다.

| Code | 의미                                 |
| ---- | ------------------------------------ |
| `0`  | lint 문제 없음                       |
| `1`  | lint 문제 발견                       |
| `2`  | 잘못된 명령줄 사용                   |
| `3`  | 치명적 오류(예: 파일을 읽을 수 없음) |

입력값이 잘못된 경우(예: `no-color: maybe`) 래퍼는 code `2`로 종료하고 명확한 오류 메시지를 출력합니다.

## Config file

actionlint는 `.github/actionlint.yaml` 또는 `.github/actionlint.yml`을 자동으로 읽습니다. `config-file` 입력으로 다른 config 파일을 지정할 수도 있습니다.

## 보안

- `Dockerfile`에서 업스트림 이미지는 [tag와 SHA256 digest로 고정](https://github.com/windlasstech/.github/blob/main/docs/security/workflow-hardening.md#action-references)되어 있습니다.
- Dependabot이 매주 Docker base image 및 외부 GitHub Actions 업데이트를 확인하고 제안하도록 구성되어 있습니다.
- 이 저장소는 [Windlass 재사용 가능 워크플로우](https://github.com/windlasstech/.github#cicd-workflows)를 사용하여 OpenSSF Scorecard, OSV Scanner, Dependency Review를 실행합니다.
- 호출 워크플로우는 일반적으로 `contents: read`와 같은 [최소 권한](https://github.com/windlasstech/.github/blob/main/docs/security/workflow-hardening.md#permission-management)만 사용해야 합니다.

## 버전 관리

이 action은 업스트림 actionlint 버전과 독립적인 [Semantic Versioning](https://semver.org/)을 사용합니다. 릴리스 노트에는 포함된 actionlint 버전을 명확히 표시합니다(예: `v1.0.0 - includes actionlint v1.7.12`).

## 라이선스

[LICENSE](./LICENSE)를 참조하세요.
