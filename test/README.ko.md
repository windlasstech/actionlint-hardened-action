# 테스트 픽스처

이 디렉터리는 `actionlint-action` 자체 테스트 워크플로우를 위한 고정 테스트 입력(픽스처)을 포함합니다. 이 픽스처들은 프로덕션 코드가 구현되기 전에 wrapper action의 동작 계약을 미리 정의합니다.

## 픽스처를 사용하는 이유

픽스처는 테스트 주도 접근 방식을 따릅니다. 기대 동작을 먼저 정의한 뒤, wrapper 구현을 이 픽스처에 대해 검증합니다. 이를 통해 GitHub Actions 워크플로우에서 로컬 action(`uses: ./`)을 실행하고 각 시나리오의 구체적인 결과를 검증할 수 있습니다.

## 픽스처 구성

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

## 픽스처

### `valid/.github/workflows/valid.yml`

최소 구성의, 문법적으로 유효한 GitHub Actions 워크플로우입니다.

- **목적**: 정상 경로를 검증합니다.
- **기대 결과**: `actionlint`가 문제 없이 `0`으로 종료합니다.
- **paths 입력 동작**: 단일 파일, glob, 미매칭 glob, 여러 줄 `paths`, 빈 값 자동 탐색 자체 테스트 시나리오에 사용합니다.
- **디렉터리 입력 동작**: `test/fixtures/valid/.github/workflows`를 디렉터리로 전달하면 `actionlint` CLI와 동일하게 실패해야 합니다.

### `invalid/.github/workflows/invalid.yml`

구조적 오류를 포함하는 워크플로우입니다.

- **목적**: 실패 경로를 검증합니다.
- **기대 결과**: 워크플로우 단의 알 수 없는 `foo` key 때문에 `actionlint`가 `1`로 종료합니다.
- **알려진 오류**: `unexpected key "foo" for "workflow" section`.
- **출력 동작**: wrapper가 생성하는 `format`, `no-color`, `oneline` 출력의 정확한 내용을 검증하는 데 사용합니다.

### `config/.github/workflows/ignored.yml`

짝이 되는 config 파일의 ignore 규칙과 일치하는 오류를 포함하는 워크플로우입니다.

- **목적**: `config-file` 입력과 `ignore` 입력을 검증합니다.
- **기대 결과**:
  - config 없음: `actionlint`가 `1`로 종료합니다.
  - `config-file: test/fixtures/config/.github/actionlint.yaml` 사용: `actionlint`가 `0`으로 종료합니다.
  - `ignore: 'unexpected key "foo" for "workflow" section.*'` 사용: `actionlint`가 `0`으로 종료합니다.

### `config/.github/actionlint.yaml`

`ignored.yml`과 짝을 이루는 actionlint config 파일입니다.

- **목적**: config-file 시나리오가 통과하도록 `ignored.yml`의 알려진 오류를 억제합니다.
- **규칙**: `unexpected key "foo" for "workflow" section`과 일치하는 오류를 무시합니다.

### `dash-leading/.github/workflows/valid.yml`

실행 시 `-dash-leading-valid.yml` 이름으로 복사되는 최소 구성의 유효한 workflow 파일입니다.

- **목적**: `-`로 시작하는 `paths` 항목이 option separator 뒤에 전달되어 `actionlint` flag로 해석될 수 없음을 검증합니다.
- **기대 결과**: `actionlint`가 문제 없이 `0`으로 종료합니다.

## 사용 방식

`.github/workflows/actionlint-self-test.yml`의 자체 테스트 워크플로우는 각 픽스처에 대해 로컬 action을 실행하고 기대 결과를 검증합니다. 이를 통해 다음을 보장합니다.

- 필수 입력을 `actionlint` CLI 인자로 올바르게 매핑하며, 단일 파일, glob, 미매칭 glob, 여러 줄, 빈 값 자동 탐색, dash-leading, CLI-equivalent 디렉터리 실패 시나리오를 검증합니다.
- `config-file`, `ignore`, `shellcheck`, `pyflakes` 같은 선택 입력이 문서화한 대로 동작하며, fake ShellCheck 명령으로 빈 문자열 ShellCheck 비활성화도 검증합니다.
- `format`, `no-color`, `oneline` 같은 출력 형식 입력이 ANSI escape sequence 없이 기대한 텍스트를 생성하며, `oneline`은 custom `format`과 별도로 검증합니다.
- wrapper가 내부 `actionlint` 프로세스와 동일한 코드로 종료합니다.

## 새 픽스처 추가

새 픽스처를 추가할 때는 다음을 수행합니다.

1. 적절한 하위 디렉터리에 배치합니다.
2. 이 파일에 목적과 기대 결과를 문서화합니다.
3. `.github/workflows/actionlint-self-test.yml`에 해당 step을 추가합니다.
4. 커밋하기 전에 `actionlint` CLI로 픽스처를 로컬에서 검증합니다.
