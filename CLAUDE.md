# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

틱택토 & 오목 보드 게임 앱. AI 대전(Minimax 알고리즘) 및 2인 로컬 대전을 지원하며, 3가지 AI 난이도와 승패 통계를 제공합니다.

- 패키지명: `com.dangundad.tictactoe`
- 개발사: DangunDad (`dangundad@gmail.com`)
- 설계 크기: 375x812 (ScreenUtil 기준)
- 테마: `FlexScheme.sakura` (라이트/다크 모두)

## 기술 스택

| 영역 | 기술 |
|------|------|
| 상태 관리 | GetX (`GetxController`, `GetTickerProviderStateMixin`) |
| 로컬 저장 | Hive_CE (설정/앱 데이터 박스) |
| UI 반응형 | flutter_screenutil |
| 테마 | flex_color_scheme (`FlexScheme.sakura`) |
| 보드 렌더링 | CustomPainter (`BoardPainter`) |
| AI | Minimax + Alpha-Beta Pruning (틱택토), 패턴 스코어링 (오목) |
| 광고 | google_mobile_ads + AdMob 미디에이션 |
| 인앱 구매 | in_app_purchase |
| 다국어 | GetX 번역 (ko) |

## 개발 명령어

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

## 아키텍처

### 프로젝트 구조

```
lib/
├── main.dart
├── hive_registrar.g.dart
├── app/
│   ├── admob/
│   │   ├── ads_banner.dart
│   │   ├── ads_helper.dart
│   │   ├── ads_interstitial.dart
│   │   └── ads_rewarded.dart
│   ├── bindings/
│   │   └── app_binding.dart
│   ├── controllers/
│   │   ├── game_controller.dart     # 게임 핵심 로직 + AI
│   │   ├── history_controller.dart
│   │   ├── home_controller.dart
│   │   ├── premium_controller.dart
│   │   ├── setting_controller.dart
│   │   └── stats_controller.dart
│   ├── data/
│   │   └── enums/
│   │       ├── ai_difficulty.dart    # easy, medium, hard
│   │       ├── game_mode.dart        # vsAI, vs2P
│   │       ├── game_status.dart      # idle, playing, gameOver
│   │       └── game_type.dart        # tictactoe, gomoku
│   ├── pages/
│   │   ├── game/
│   │   │   ├── game_page.dart
│   │   │   └── widgets/
│   │   │       └── board_painter.dart  # CustomPainter 보드 렌더링
│   │   ├── history/history_page.dart
│   │   ├── home/home_page.dart
│   │   ├── premium/
│   │   │   ├── premium_binding.dart
│   │   │   └── premium_page.dart
│   │   ├── settings/settings_page.dart
│   │   └── stats/stats_page.dart
│   ├── routes/
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   ├── services/
│   │   ├── activity_log_service.dart
│   │   ├── app_rating_service.dart
│   │   ├── hive_service.dart
│   │   └── purchase_service.dart
│   ├── theme/
│   │   └── app_flex_theme.dart
│   ├── translate/
│   │   └── translate.dart
│   ├── utils/
│   │   └── app_constants.dart
│   └── widgets/
│       └── confetti_overlay.dart
```

### 서비스 초기화 흐름

`main()` -> AdMob 동의 폼 초기화 -> `AppBinding.initializeServices()` (Hive 초기화 + 서비스 등록) -> `runApp()`

### GetX 의존성 트리

**영구 서비스 (permanent: true)**
- `HiveService` -- Hive 박스 관리
- `ActivityLogService` -- 이벤트 로그
- `PurchaseService` -- IAP 관리
- `GameController` -- 게임 상태 + AI 로직 (GetTickerProviderStateMixin 사용)
- `SettingController` -- 앱 설정
- `InterstitialAdManager` / `RewardedAdManager` -- 광고 (비프리미엄 시)

**LazyPut (필요 시 생성)**
- `HistoryController`, `StatsController`, `PremiumController`

### 라우팅

| 경로 | 페이지 | 바인딩 |
|------|--------|--------|
| `/home` | `HomePage` | `AppBinding` |
| `/game` | `GamePage` | -- |
| `/settings` | `SettingsPage` | -- |
| `/history` | `HistoryPage` | -- |
| `/stats` | `StatsPage` | -- |
| `/premium` | `PremiumPage` | `PremiumBinding` |

### 게임 핵심 구조

**GameController**가 모든 게임 로직을 관리합니다:
- **보드**: `List<List<int>>` (0=빈칸, 1=Player1, 2=Player2/AI)
- **틱택토**: 3x3 그리드, 3연속 승리
- **오목**: 15x15 그리드, 정확히 5연속 승리 (6+ overline은 미승리)

**AI 알고리즘**:
- 틱택토: Minimax + Alpha-Beta Pruning (완전 탐색)
  - Easy: 완전 랜덤
  - Medium: 35% 확률로 랜덤, 나머지 Minimax
  - Hard: 순수 Minimax (무적)
- 오목: 패턴 스코어링 기반 탐색
  - 위협 탐지: 5연속 완성/차단 -> 4연속 열린 -> 3연속 열린
  - 후보 셀: 기존 돌 주변 2칸 이내만 탐색 (성능 최적화)
  - 공격/방어 점수 비율: 방어 1.1배 가중

**보상형 광고 AI 업그레이드**: 광고 시청 시 해당 게임 동안 Hard 난이도로 임시 상향

### 승선 애니메이션

- `AnimationController`로 승리 라인 그리기 애니메이션 (600ms)
- `BoardPainter`에서 `winProgress` 값으로 라인 진행률 반영
- 승리 시 confetti 오버레이 표시

### 통계 저장

| 키 | 용도 |
|----|------|
| `ttt_wins/losses/draws` | 틱택토 승/패/무 |
| `go_wins/losses/draws` | 오목 승/패/무 |

### 다국어

현재 `ko` 키만 정의. 새 문자열은 `lib/app/translate/translate.dart`에 `ko` 섹션에만 추가.

## 개발 가이드라인

- AI 로직은 `GameController` 내부에 집중 (`_aiMoveTTT`, `_aiMoveGomoku`)
- 보드 상태 변경 후 `board.refresh()` 필수 (GetX 리스트 반응성)
- `GetTickerProviderStateMixin` 사용 -> `winAnim`을 `onClose()`에서 dispose
- 오목 overline (6+) 처리: `_findWinLine`에서 `count == target` 정확 매칭
