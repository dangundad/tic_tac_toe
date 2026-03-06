# Tic-Tac-Toe & Gomoku - TODO

## 구현 완료 기능

- [x] 틱택토 (3x3) 게임 모드
- [x] 오목 (15x15) 게임 모드
- [x] AI 대전 (vsAI) - 3단계 난이도 (Easy/Medium/Hard)
- [x] 2인 로컬 대전 (vs2P)
- [x] 틱택토 AI: Minimax + Alpha-Beta Pruning (Hard에서 무적)
- [x] 오목 AI: 패턴 스코어링 기반 탐색 (위협 탐지 + 후보 셀 제한)
- [x] 오목 overline (6+) 미승리 처리
- [x] 보상형 광고 AI 업그레이드 (해당 게임 동안 Hard로 임시 상향)
- [x] 승리 라인 애니메이션 (AnimationController, 600ms)
- [x] Confetti 효과 (플레이어 승리 시)
- [x] 통계: 틱택토/오목 각각 승/패/무 기록 (Hive 저장)
- [x] 햅틱 피드백 (돌 놓기, 승리, 무승부)
- [x] CustomPainter 보드 렌더링 (BoardPainter)
- [x] GetX 상태 관리 + 라우팅
- [x] Hive_CE 로컬 저장
- [x] AdMob 광고 (배너 + 전면 + 보상형) + 미디에이션
- [x] 인앱 구매 (프리미엄 광고 제거)
- [x] 다국어 지원 (ko)
- [x] FlexColorScheme 테마 (sakura)
- [x] 설정 페이지
- [x] 통계 페이지
- [x] 활동 로그 서비스

## 출시 전 남은 작업

- [ ] AdMob 실제 광고 ID 교체 (현재 테스트 ID)
- [ ] 인앱 구매 상품 ID 등록 (Google Play Console)
- [ ] 앱 아이콘 제작 및 적용 (`dart run flutter_launcher_icons`)
- [ ] 스플래시 화면 제작 및 적용 (`dart run flutter_native_splash:create`)
- [ ] Google Play 스토어 등록 (스크린샷, 설명, 카테고리)
- [ ] Apple App Store 등록
- [ ] 다국어 확장 (en, ja 등)
- [ ] Privacy Policy 페이지 작성
- [ ] ProGuard 규칙 확인 (릴리스 빌드)
- [ ] Firebase Crashlytics 설정 확인
- [ ] AI 턴 중 앱 백그라운드 진입 시 안정성 확인
- [ ] 오목 15x15 대형 보드 성능 최적화 검증
- [ ] 광고 로딩 실패 시 게임 플로우 중단 없는지 확인
