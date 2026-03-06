# Tic-Tac-Toe & Gomoku

틱택토와 오목을 AI 또는 2인 로컬 대전으로 즐길 수 있는 Flutter 보드 게임 앱입니다.

## 주요 기능

- **2가지 게임 모드**: 틱택토 (3x3) + 오목 (15x15)
- **AI 대전**: Minimax 알고리즘 기반 3단계 난이도 (Easy/Medium/Hard)
- **2인 로컬 대전**: 같은 기기에서 번갈아 플레이
- **AI 업그레이드**: 보상형 광고 시청 시 해당 게임 동안 Hard 난이도로 임시 상향
- **승리 라인 애니메이션**: 승리 시 라인 그리기 + Confetti 효과
- **통계**: 틱택토/오목 각각 승/패/무 기록
- **햅틱 피드백**: 돌 놓기, 승리, 무승부 시 진동
- **프리미엄**: 인앱 구매로 광고 제거

## 기술 스택

- **Flutter** (Dart)
- **GetX** - 상태 관리, 라우팅, 다국어
- **Hive_CE** - 로컬 데이터 저장
- **CustomPainter** - 보드 렌더링 (`BoardPainter`)
- **Minimax + Alpha-Beta Pruning** - 틱택토 AI
- **패턴 스코어링** - 오목 AI
- **flex_color_scheme** - 테마 (`FlexScheme.sakura`)
- **flutter_screenutil** - 반응형 UI
- **google_mobile_ads** - AdMob 광고 (배너 + 전면 + 보상형)

## 설치 및 실행

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

## 프로젝트 구조

```
lib/
├── main.dart
├── app/
│   ├── admob/              # AdMob 광고 관리
│   ├── bindings/           # GetX 바인딩
│   ├── controllers/        # GameController (AI 포함), SettingController 등
│   ├── data/enums/         # GameType, GameMode, AiDifficulty, GameStatus
│   ├── pages/              # 화면별 UI (game/ 하위에 BoardPainter)
│   ├── routes/             # GetX 라우팅
│   ├── services/           # HiveService, PurchaseService 등
│   ├── theme/              # FlexColorScheme 테마
│   ├── translate/          # 다국어 (ko)
│   ├── utils/              # 상수 정의
│   └── widgets/            # ConfettiOverlay
```

## 라이선스

Copyright 2026 DangunDad. All rights reserved.
