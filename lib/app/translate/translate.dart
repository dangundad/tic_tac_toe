import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Languages extends Translations {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ko'),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      // Common
      'settings': 'Settings',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'reset': 'Reset',
      'done': 'Done',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'error': 'Error',
      'home': 'Home',
      'rate_app': 'Rate App',
      'privacy_policy': 'Privacy Policy',
      'remove_ads': 'Remove Ads',
      'send_feedback': 'Send Feedback',
      'more_apps': 'More Apps',

      // App-specific
      'app_name': 'Tic-Tac-Toe & Gomoku',
      'tic_tac_toe': 'Tic-Tac-Toe',
      'gomoku': 'Gomoku',
      'game_type': 'GAME TYPE',
      'game_mode': 'MODE',
      'difficulty': 'DIFFICULTY',
      'vs_ai': 'vs AI',
      'vs_friend': 'vs Friend',
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',
      'stats': 'STATS',
      'wins': 'Wins',
      'losses': 'Losses',
      'draws': 'Draws',
      'win_rate': 'Win rate',
      'no_games_yet': 'No games played yet',
      'start_game': 'Start Game',
      'restart': 'Restart',

      // Game status
      'your_turn': 'Your Turn',
      'ai_thinking': 'AI Thinking...',
      'p1_turn_x': 'Player 1 (X)',
      'p2_turn_o': 'Player 2 (O)',
      'p1_turn_b': 'Player 1 (Black)',
      'p2_turn_w': 'Player 2 (White)',
      'ready': 'Ready',
      'draw': 'Draw!',

      // Result
      'you_win': 'You Win!',
      'ai_wins': 'AI Wins',
      'p1_wins': 'Player 1 Wins!',
      'p2_wins': 'Player 2 Wins!',
      'beat_ai': 'Great job beating the AI!',
      'try_again': 'Better luck next time!',
      'well_played': 'Well played!',
      'close_game': "It's a close one!",
      'play_again': 'Play Again',
    },
    'ko': {
      // 공통
      'settings': '설정',
      'save': '저장',
      'cancel': '취소',
      'delete': '삭제',
      'edit': '편집',
      'reset': '초기화',
      'done': '완료',
      'ok': '확인',
      'yes': '예',
      'no': '아니오',
      'error': '오류',
      'home': '홈',
      'rate_app': '앱 평가',
      'privacy_policy': '개인정보처리방침',
      'remove_ads': '광고 제거',
      'send_feedback': '피드백 보내기',
      'more_apps': '더 많은 앱',

      // 앱별
      'app_name': '틱택토 & 오목',
      'tic_tac_toe': '틱택토',
      'gomoku': '오목',
      'game_type': '게임 선택',
      'game_mode': '모드',
      'difficulty': '난이도',
      'vs_ai': 'AI 대전',
      'vs_friend': '2인 대전',
      'easy': '쉬움',
      'medium': '보통',
      'hard': '어려움',
      'stats': '전적',
      'wins': '승',
      'losses': '패',
      'draws': '무',
      'win_rate': '승률',
      'no_games_yet': '아직 게임 기록이 없습니다',
      'start_game': '게임 시작',
      'restart': '다시 시작',

      // 게임 상태
      'your_turn': '당신의 차례',
      'ai_thinking': 'AI 생각 중...',
      'p1_turn_x': '플레이어 1 (X)',
      'p2_turn_o': '플레이어 2 (O)',
      'p1_turn_b': '플레이어 1 (흑)',
      'p2_turn_w': '플레이어 2 (백)',
      'ready': '준비',
      'draw': '무승부!',

      // 결과
      'you_win': '승리!',
      'ai_wins': 'AI 승리',
      'p1_wins': '플레이어 1 승리!',
      'p2_wins': '플레이어 2 승리!',
      'beat_ai': 'AI를 이겼어요!',
      'try_again': '다음엔 이길 수 있어요!',
      'well_played': '잘 하셨어요!',
      'close_game': '아슬아슬한 게임이었네요!',
      'play_again': '다시 하기',
    },
  };
}
