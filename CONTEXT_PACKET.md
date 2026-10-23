# CONTEXT PACKET — 5주차 상태 기능과 작업 컨텍스트

## 1. 목표 (Goal)
- 입력(체크박스 클릭)에 반응하여 완료/취소 상태가 토글되는 Flutter 상태 기능 구현
- 원본 상태와 계산값을 명확히 구분하여 데이터 중복 저장을 방지하는 상태 구조 설계

## 2. 현재 코드 구조 (Current Code)
- **주요 파일:** `lib/main.dart`
- **데이터 모델:** `TaskItem` (id, title, isCompleted)
- **상태 관리 클래스:** `_TaskListScreenState` (StatefulWidget)

## 3. 상태 관리 근거 (Rationale)
- 단일 진실 원천(Single Source of Truth) 원칙을 적용하여 `_tasks` 리스트만을 원본 상태로 보유합니다.
- 진행률, 완료 개수 등의 파생 데이터는 State 변수로 따로 두지 않고 `getter`로 동적 산출하여 데이터 불일치(Inconsistency) 위험을 차단했습니다.

## 4. 제약 조건 (Constraints)
- 외부 상태 관리 패키지(Provider, Bloc, Riverpod 등) 미사용 (`setState` 기본 기능 활용)
- Windows 일반 명령 프롬프트(CMD) 환경에서 명령어 실행
- 계산 가능한 값을 별도 저장 금지 (AC4)

## 5. 인수 조건 (Acceptance Criteria)
- [x] **AC1:** 초기 실행 시 `_tasks` 기본 데이터와 UI 표시값(0% 완료)이 일치한다.
- [x] **AC2:** 체크박스를 클릭하면 즉시 상태 및 화면(체크, 취소선, 진행률)이 바뀐다.
- [x] **AC3:** 체크된 항목을 다시 클릭하면 이전 미완료 상태 및 화면으로 원복된다.
- [x] **AC4:** completedCount, progressRate는 별도 변수가 아닌 getter로 계산한다.
- [x] **AC5:** 작업 맥락의 파일, 제약, AC가 실제 코드 구현과 일치한다.
- [x] **AC6:** 프롬프트 A/B 응답 결과를 동일 기준으로 비교 관찰한다.
- [x] **AC7:** 상태 기능, 문서, 화면 증거가 하나의 기능을 일관되게 가리킨다.

## 6. 검증 방식 (Verification)
- `flutter analyze` 실행을 통한 정적 코드 오류 및 경고 0건 검증
- 앱 실행을 통한 초기 화면 → 상태 변경 화면 → 원복 화면 동작 확인