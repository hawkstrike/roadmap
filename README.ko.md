# Roadmap 스킬

[English](README.md)

`roadmap`은 Codex, Claude Code, OpenClaw를 비롯한 [Agent Skills](https://agentskills.io/) 호환 에이전트에서 사용할 수 있는 공용 스킬입니다. 기존 로드맵을 변경하지 않고 점검하거나, 중요한 계획 질문을 확인한 뒤 독립적으로 검증 가능한 작업 세션이 포함된 단일 기준 로드맵을 구성합니다.

읽기 전용 점검을 수행하거나 로드맵을 새로 만들거나 목표·우선순위·구조를 크게 변경할 때 스킬을 호출합니다. 생성된 세션 프롬프트는 자립적으로 동작하며, 각 세션이 로드맵을 갱신하고 후속 프롬프트를 생성하므로 이후 세션에서는 스킬을 다시 호출할 필요가 없습니다.

## 주요 기능

- 계획 전에 적용되는 사용자·프로젝트 지침, 사용 가능한 프로젝트 메모리, 문서, Git 상태, 구현, 테스트, 검증 설정을 확인합니다.
- 점검만 요청받으면 우선순위가 지정된 발견 사항을 보고하고 파일을 변경하지 않은 채 종료합니다.
- 메모리와 과거 인계 자료는 조사 시작점으로 활용하고, 변동 가능한 내용은 현재 근거로 재확인합니다.
- 중요한 가정으로 로드맵을 작성하지 않고, 가장 영향이 큰 미확정 사항을 한 메시지에 한 주제씩 질문합니다.
- 의존성과 위험을 고려한 세션 순서를 제안하고, 우선순위를 확정하기 전에 사용자 승인을 받습니다.
- 큰 작업을 하나의 주된 결과, 명확한 범위, 선행 조건, 공유 경계, 완료 기준, 검증 항목이 있는 세션으로 나눕니다.
- 병행 작업에 소유 경계, 로드맵 갱신 책임, 합류 지점을 지정합니다.
- 상세형 또는 축약형 자립형 프롬프트 중 사용자가 선택한 프로젝트 정책을 유지합니다.
- 필수 완료 근거가 부족하면 같은 세션을 유지합니다.
- 프로젝트 지침이 구체적인 규칙을 제공하지 않을 때 조사 우선, 최소 변경, 테스트, 디버깅, 의존성, 검증 기본 규율을 적용합니다.

## 설치

사용하는 도구에만 각각 설치하면 됩니다. Claude Code와 Codex를 모두 설치할 필요는 없습니다. 설치가 끝나면 새 세션을 시작해 스킬을 불러와 주세요.

### 권장: `/plugin`으로 설치하기

#### Codex

1. Codex에서 `/plugin`을 입력합니다.
2. 마켓플레이스 관리 화면에서 GitHub 저장소 `hawkstrike/roadmap`을 추가합니다.
3. 추가된 `roadmap` 마켓플레이스에서 **Roadmap** 플러그인을 선택해 설치합니다.
4. 새 Codex 세션에서 `$roadmap`으로 호출합니다.

#### Claude Code

Claude Code에서 다음 명령을 순서대로 입력합니다.

```text
/plugin marketplace add hawkstrike/roadmap
/plugin install roadmap@roadmap
```

설치 후 새 Claude Code 세션에서 `/roadmap`으로 호출합니다.

### 대안: GitHub와 `npx skills`

명령 이름은 `npx skills`처럼 `skills`가 복수형입니다. CLI는 이 GitHub 저장소를 직접 읽고 원본 정보와 스킬 폴더 해시를 기록하므로 나중에 설치본을 갱신할 수 있습니다. 지원되는 Node.js 버전이 있으면 macOS, Windows, Linux에서 동일하게 사용할 수 있습니다.

Node.js 22.20 이상이 필요합니다. 사용하는 도구에 해당하는 명령 하나만 실행하세요.

```bash
npx skills add hawkstrike/roadmap --skill roadmap --global --agent codex
npx skills add hawkstrike/roadmap --skill roadmap --global --agent claude-code
```

설치 방식을 묻는 메시지가 나오면 권장 항목을 선택하세요.

프로젝트 설치본은 해당 프로젝트 경로에서 갱신하고, 전역 설치본은 어느 경로에서나 갱신할 수 있습니다.

```bash
npx skills update roadmap --project
npx skills update roadmap --global
```

`skills` CLI는 자체 설치 경로와 잠금 파일을 관리합니다. 같은 도구와 범위에 `/plugin` 설치와 `npx skills` 설치를 함께 사용하지 마세요.

### 다른 호환 에이전트에 설치하기

Agent Skills 호환 도구가 `~/.agents/skills`를 읽지 않는다면 전체 `roadmap` 디렉터리를 해당 도구의 공식 스킬 경로에 복사해 주세요.

```bash
cp -R roadmap /path/to/agent/skills/roadmap
```

스킬이 상대 경로로 참고 문서를 읽으므로 `SKILL.md`, `references/`와 나머지 파일을 함께 유지해야 합니다. 호출 방법은 사용하는 도구의 문서를 따르며, frontmatter의 `name`을 슬래시 명령으로 제공하는 도구에서는 일반적으로 `/roadmap`을 사용합니다.

## 사용법

읽기 전용 점검을 수행하거나 새 로드맵을 만들거나 기존 로드맵의 목표·우선순위·구조를 다시 결정할 때 스킬을 명시적으로 호출합니다. 나머지 요청은 사용하는 도구가 지원하는 언어로 작성할 수 있으며, 스킬은 사용자와 프로젝트 지침을 따릅니다.

읽기 전용 점검에서는 기존 로드맵을 현재 프로젝트 근거와 비교하도록 요청합니다. 스킬은 순서나 프롬프트 형식 승인을 요구하지 않고 발견 사항을 보고하며, 사용자가 이후 수정을 요청하지 않는 한 로드맵을 변경하지 않습니다.

### Codex

```text
$roadmap 이 저장소를 확인하고 팀 기반 접근 제어 기능을 위한 로드맵을 작성해 주세요. 중요한 미확정 사항을 한 번에 한 주제씩 확인한 뒤 승인된 범위를 독립적으로 검증 가능한 세션으로 나눠 주세요.
```

### Claude Code

```text
/roadmap 이 저장소를 확인하고 팀 기반 접근 제어 기능을 위한 로드맵을 작성해 주세요. 중요한 미확정 사항을 한 번에 한 주제씩 확인한 뒤 승인된 범위를 독립적으로 검증 가능한 세션으로 나눠 주세요.
```

### OpenClaw

```text
/roadmap 이 저장소를 확인하고 팀 기반 접근 제어 기능을 위한 로드맵을 작성해 주세요. 중요한 미확정 사항을 한 번에 한 주제씩 확인한 뒤 승인된 범위를 독립적으로 검증 가능한 세션으로 나눠 주세요.
```

### 그 밖의 호환 에이전트

사용하는 도구의 스킬 선택기, 슬래시 명령 또는 명시적 스킬 호출 문법으로 설치된 `roadmap` 스킬을 실행해 주세요. 스킬 자체는 Codex나 Claude 전용 도구에 의존하지 않습니다.

## 생성 및 수정 흐름

1. 현재 지침, 메모리, 문서, Git, 구현, 테스트, 검증 근거를 조사합니다.
2. 목표와 범위가 명확해질 때까지 중요한 발견 질문을 한 번에 하나씩 진행합니다.
3. 세션 순서와 병행 트랙을 제안하고 중요한 선택의 장단점을 설명한 뒤 승인을 받습니다.
4. 로드맵에 프롬프트 정책이 없으면 상세형 또는 축약형을 선택하도록 질문합니다.
5. 단일 기준 로드맵을 작성하거나 갱신하고 첫 자립형 세션 프롬프트를 생성합니다.
6. 각 세션이 로드맵을 갱신하고 다음 프롬프트를 생성합니다.

후속 프롬프트는 단일 기준 로드맵을 읽고 현재 범위, 검증, 완료 판정, 종료, 인계 규칙을 직접 전달합니다. 이전 대화 내용이나 스킬의 반복 호출에 의존하지 않습니다.

## 프롬프트 형식

### 상세형

상세형 프롬프트는 공통 실행 규율, 완료 판정, 종료 순서, 인계 요건을 매번 포함합니다. 길지만 프로젝트 지침이 적거나 실행 환경이 달라져도 안정적으로 전달됩니다.

### 축약형

축약형 프롬프트는 지속적인 규칙을 단일 기준 로드맵에서 읽고, 현재 세션의 범위·근거·종료·인계 정보만 전달합니다. 짧지만 로드맵이 정확하게 유지되어야 합니다.

선택한 형식은 사용자가 명시적으로 변경할 때까지 완료 세션과 미완료 세션의 프롬프트에 함께 적용됩니다.

## 세션 동작

세션 프롬프트에는 작업 경로, 적용 지침, 단일 기준 로드맵, 이전 결과, 현재 목표, 포함·제외 범위, 선행 조건, 공유 소유권, 완료 기준, 필수 검증이 들어갑니다. 사용자 소유 변경을 보존하고 완료 전에 새로운 검증 근거를 요구합니다.

세션 종료 시 구현 내용, 검증 결과, Git 상태, 위험 요소를 보고하고 로드맵의 완료 근거, 상태, 현재·다음 세션, 변경 이력을 갱신한 뒤 후속 자립형 프롬프트를 생성합니다. 세션 상태는 `✅ 완료`, `🔄 진행 중`, `⏳ 대기`, `❌ 차단`처럼 이모지와 글자를 항상 함께 표시합니다. 검증이 실패하거나 빠졌다면 다음 세션으로 넘어가지 않고 같은 세션의 이어서 작업할 프롬프트를 생성합니다.

병행 프롬프트는 파일, 데이터, 외부 자원, 로드맵 갱신 소유권을 분리합니다. 공유 상위 로드맵은 한 소유자 또는 합류 세션이 갱신합니다.

## 프로젝트 구조

```text
.agents/plugins/
└── marketplace.json
.claude-plugin/
├── marketplace.json
└── plugin.json
.codex-plugin/
└── plugin.json
roadmap/
├── SKILL.md
├── agents/
│   └── openai.yaml
├── references/
│   ├── roadmap-structure.md
│   └── session-closeout.md
└── scripts/
    └── install.sh
```

- `.agents/plugins/marketplace.json`은 Codex에 저장소의 플러그인 목록을 제공합니다.
- `.claude-plugin/marketplace.json`은 Claude Code에 저장소의 플러그인 목록을 제공합니다.
- Claude Code와 Codex의 `plugin.json`은 플러그인 메타데이터와 `roadmap/` 스킬 경로를 정의합니다.
- `SKILL.md`는 발견 질문, 승인, 최초 구성 절차를 정의합니다.
- `references/roadmap-structure.md`는 지속적인 로드맵 규율, 세션 크기, 순서, 병행 소유권을 정의합니다.
- `references/session-closeout.md`는 완료 판정과 상세형·축약형 자립형 프롬프트 형식을 정의합니다.
- `agents/openai.yaml`은 Codex 전용 표시 정보를 제공합니다.
- `scripts/install.sh`는 기존 복사 설치 사용자를 위한 설치·업데이트 스크립트입니다.

## 개발 및 검증

저장소 루트에서 이식 가능한 설치·콘텐츠 회귀 테스트와 구조 검사를 실행합니다.

```bash
bash tests/install-roadmap-skill.sh
bash tests/validate-installation-docs.sh
bash tests/validate-roadmap-content.sh
bash -n roadmap/scripts/install.sh
git diff --check
```

Codex 개발 환경에서는 상위 스킬 구조 검증기도 추가로 실행합니다.

```bash
python3 "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py" roadmap
```
