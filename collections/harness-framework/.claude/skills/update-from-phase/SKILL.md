---
name: update-from-phase
description: Phase 완료 시 PM이 직접 트리거한다. dev-plan.md Phase 상태 갱신, CLAUDE.md 및 memory 갱신, git commit & push를 일괄 처리한다. "phase 완료", "update-from-phase", "phase 업데이트" 표현이 나오면 트리거한다. task 단위 갱신은 PM이 직접 수행하며 이 스킬은 덮어쓰지 않는다.
---

이 스킬은 **PM이 직접 트리거**한다. 필요한 컨텍스트:
- `<플랜번호>`: 현재 세션 플랜 번호
- `<완료된 Phase 번호>`: 방금 완료된 Phase 번호
- `<다음 Phase 번호>`: 이제 시작될 Phase 번호 (마지막 Phase면 "없음")

---

## STEP 1 — dev-plan.md 갱신

`_workspace/<플랜번호>/<플랜번호>-dev-plan.md`를 읽어 다음을 수정한다:

- 완료된 Phase의 `**상태**`를 `완료`로 변경
- 다음 Phase의 `**상태**`를 `진행 중`으로 변경 (있으면)
- `## 현재 상태` 섹션 갱신:
  - **진행 중인 Phase**: <다음 Phase 또는 "완료">
  - **진행 중인 Task**: <다음 Phase의 첫 task 또는 "없음">
  - **다음 작업**: <설명>

PM이 task마다 갱신한 체크박스는 건드리지 않는다.

---

## STEP 2 — CLAUDE.md 갱신 (있으면)

프로젝트 루트의 `CLAUDE.md`가 있으면 현재 하네스 상태를 반영하여 갱신한다:
- 새로 추가된 에이전트/스킬 목록 업데이트
- 현재 진행 중인 세션 정보 업데이트

CLAUDE.md가 없으면 이 단계를 건너뛴다.

---

## STEP 3 — memory 갱신

memory 시스템(`~/.claude/projects/.../memory/`)에 프로젝트 상태를 기록한다:
- 완료된 Phase 내용 요약
- 생성된 새 에이전트/스킬 정보
- 다음 Phase 계획

---

## STEP 4 — git commit & push

`/clean-commit` 스킬을 사용하여 커밋한다.

커밋 메시지 형식:
```
chore(phase-<N>): Phase <N> <Phase 이름> 완료

- <주요 산출물 1>
- <주요 산출물 2>
```

remote repo가 연결되어 있으면 push한다:
```bash
git remote -v 2>/dev/null | head -1
git push 2>/dev/null && echo "pushed" || echo "no remote or push failed (non-blocking)"
```

push 실패는 에러가 아니다. 로컬 커밋만으로 완료 처리한다.

---

## STEP 5 — 완료 보고

```
update-from-phase 완료
- Phase <N> → 완료 마킹
- Phase <N+1> → 진행 중으로 전환
- 커밋: <hash> <message>
- Push: 성공 / 스킵 (no remote)
```
