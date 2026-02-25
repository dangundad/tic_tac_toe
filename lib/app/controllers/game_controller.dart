import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:tic_tac_toe/app/admob/ads_rewarded.dart';
import 'package:tic_tac_toe/app/data/enums/ai_difficulty.dart';
import 'package:tic_tac_toe/app/data/enums/game_mode.dart';
import 'package:tic_tac_toe/app/data/enums/game_type.dart';
import 'package:tic_tac_toe/app/routes/app_pages.dart';
import 'package:tic_tac_toe/app/services/hive_service.dart';

enum GamePhase { idle, playing, gameOver }

class GameController extends GetxController with GetTickerProviderStateMixin {
  static GameController get to => Get.find();

  static const _tttWK = 'ttt_wins';
  static const _tttLK = 'ttt_losses';
  static const _tttDK = 'ttt_draws';
  static const _goWK = 'go_wins';
  static const _goLK = 'go_losses';
  static const _goDK = 'go_draws';

  // Settings
  final gameType = GameType.tictactoe.obs;
  final gameMode = GameMode.vsAI.obs;
  final difficulty = AiDifficulty.medium.obs;

  // AI Upgrade (rewarded ad)
  final tempAIDifficultyUpgraded = false.obs;

  // Game state
  final board = <List<int>>[].obs;
  final currentPlayer = 1.obs;
  final phase = GamePhase.idle.obs;
  final winner = 0.obs; // 0=draw/none, 1=player1, 2=player2
  final winLine = Rx<List<int>?>(null); // [r1,c1,r2,c2]
  final lastPlaced = Rx<List<int>?>(null);
  final isAiThinking = false.obs;

  // Stats
  final tttWins = 0.obs, tttLosses = 0.obs, tttDraws = 0.obs;
  final goWins = 0.obs, goLosses = 0.obs, goDraws = 0.obs;

  // Win line animation
  late AnimationController winAnim;
  final winProgress = 0.0.obs;

  // Confetti (player win only)
  final showConfetti = false.obs;

  int get gridSize => gameType.value == GameType.tictactoe ? 3 : 15;
  int get winLen => gameType.value == GameType.tictactoe ? 3 : 5;
  bool get isPlaying => phase.value == GamePhase.playing;
  bool get isGameOver => phase.value == GamePhase.gameOver;
  bool get isVsAI => gameMode.value == GameMode.vsAI;

  @override
  void onInit() {
    super.onInit();
    _loadStats();
    winAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() => winProgress.value = winAnim.value);
  }

  @override
  void onClose() {
    winAnim.dispose();
    super.onClose();
  }

  void _loadStats() {
    tttWins.value = HiveService.to.getAppData<int>(_tttWK) ?? 0;
    tttLosses.value = HiveService.to.getAppData<int>(_tttLK) ?? 0;
    tttDraws.value = HiveService.to.getAppData<int>(_tttDK) ?? 0;
    goWins.value = HiveService.to.getAppData<int>(_goWK) ?? 0;
    goLosses.value = HiveService.to.getAppData<int>(_goLK) ?? 0;
    goDraws.value = HiveService.to.getAppData<int>(_goDK) ?? 0;
  }

  void _initBoard() {
    final n = gridSize;
    board.value = List.generate(n, (_) => List.filled(n, 0));
  }

  void startGame() {
    _initBoard();
    currentPlayer.value = 1;
    phase.value = GamePhase.playing;
    winner.value = 0;
    winLine.value = null;
    lastPlaced.value = null;
    isAiThinking.value = false;
    winAnim.reset();
    winProgress.value = 0;
    Get.toNamed(Routes.GAME);
  }

  void restartGame() {
    _initBoard();
    currentPlayer.value = 1;
    phase.value = GamePhase.playing;
    winner.value = 0;
    winLine.value = null;
    lastPlaced.value = null;
    isAiThinking.value = false;
    winAnim.reset();
    winProgress.value = 0;
    showConfetti.value = false;
  }

  void placePiece(int row, int col) {
    if (!isPlaying) return;
    if (board[row][col] != 0) return;
    if (isVsAI && currentPlayer.value == 2) return;
    if (isAiThinking.value) return;

    _doPlace(row, col, currentPlayer.value);
    _afterPlace(currentPlayer.value);
  }

  void _doPlace(int row, int col, int player) {
    board[row][col] = player;
    lastPlaced.value = [row, col];
    board.refresh();
    HapticFeedback.selectionClick();
  }

  void _afterPlace(int player) {
    final line = _findWinLine(player);
    if (line != null) {
      _endGame(player, line);
      return;
    }
    if (_isBoardFull()) {
      _endGame(0, null);
      return;
    }
    currentPlayer.value = 3 - player; // toggle 1↔2
    if (isVsAI && currentPlayer.value == 2) {
      isAiThinking.value = true;
      Future.delayed(
        Duration(milliseconds: gameType.value == GameType.tictactoe ? 400 : 600),
        _doAiTurn,
      );
    }
  }

  void _doAiTurn() {
    if (!isPlaying) return;
    final move = _getAiMove();
    isAiThinking.value = false;
    if (move == null) return;
    _doPlace(move[0], move[1], 2);
    _afterPlace(2);
  }

  void requestAiUpgrade() {
    RewardedAdManager.to.showAdIfAvailable(
      onUserEarnedReward: (_) {
        tempAIDifficultyUpgraded.value = true;
        Get.snackbar(
          'ai_upgrade_title'.tr,
          'ai_upgrade_desc'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      },
    );
  }

  void _endGame(int w, List<int>? line) {
    phase.value = GamePhase.gameOver;
    winner.value = w;
    winLine.value = line;
    if (line != null) winAnim.forward();
    // Reset AI upgrade after game ends
    tempAIDifficultyUpgraded.value = false;
    _updateStats(w);

    if (w == 1) {
      HapticFeedback.mediumImpact();
      showConfetti.value = true;
    } else if (w == 0) {
      HapticFeedback.lightImpact();
    }
  }

  void dismissConfetti() {
    showConfetti.value = false;
  }

  Future<void> _updateStats(int w) async {
    final isTTT = gameType.value == GameType.tictactoe;
    if (isTTT) {
      if (w == 1) {
        tttWins.value++;
        await HiveService.to.setAppData(_tttWK, tttWins.value);
      } else if (w == 2) {
        tttLosses.value++;
        await HiveService.to.setAppData(_tttLK, tttLosses.value);
      } else {
        tttDraws.value++;
        await HiveService.to.setAppData(_tttDK, tttDraws.value);
      }
    } else {
      if (w == 1) {
        goWins.value++;
        await HiveService.to.setAppData(_goWK, goWins.value);
      } else if (w == 2) {
        goLosses.value++;
        await HiveService.to.setAppData(_goLK, goLosses.value);
      } else {
        goDraws.value++;
        await HiveService.to.setAppData(_goDK, goDraws.value);
      }
    }
  }

  bool _isBoardFull() {
    final n = gridSize;
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        if (board[r][c] == 0) return false;
      }
    }
    return true;
  }

  List<int>? _findWinLine(int player) {
    final n = gridSize;
    final target = winLen;
    const dirs = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1],
    ];
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        if (board[r][c] != player) continue;
        for (final dir in dirs) {
          final dr = dir[0], dc = dir[1];
          bool won = true;
          for (int k = 1; k < target; k++) {
            final nr = r + k * dr, nc = c + k * dc;
            if (nr < 0 || nr >= n || nc < 0 || nc >= n || board[nr][nc] != player) {
              won = false;
              break;
            }
          }
          if (won) {
            return [r, c, r + (target - 1) * dr, c + (target - 1) * dc];
          }
        }
      }
    }
    return null;
  }

  List<List<int>> _getEmptyCells() {
    final cells = <List<int>>[];
    final n = gridSize;
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        if (board[r][c] == 0) cells.add([r, c]);
      }
    }
    return cells;
  }

  // ─── AI ────────────────────────────────────────

  List<int>? _getAiMove() {
    return gameType.value == GameType.tictactoe
        ? _aiMoveTTT()
        : _aiMoveGomoku();
  }

  // ─── Effective difficulty (considering temp upgrade) ──
  AiDifficulty get _effectiveDifficulty =>
      tempAIDifficultyUpgraded.value ? AiDifficulty.hard : difficulty.value;

  // ─── Tic-Tac-Toe AI (Minimax) ──────────────────

  List<int>? _aiMoveTTT() {
    final empties = _getEmptyCells();
    if (empties.isEmpty) return null;

    if (_effectiveDifficulty == AiDifficulty.easy) {
      return empties[math.Random().nextInt(empties.length)];
    }
    if (_effectiveDifficulty == AiDifficulty.medium) {
      if (math.Random().nextDouble() < 0.35) {
        return empties[math.Random().nextInt(empties.length)];
      }
    }

    // Minimax for hard (+ medium smart)
    int bestVal = -1000;
    List<int> bestMove = empties.first;
    for (final cell in empties) {
      board[cell[0]][cell[1]] = 2;
      final val = _minimaxTTT(0, false);
      board[cell[0]][cell[1]] = 0;
      if (val > bestVal) {
        bestVal = val;
        bestMove = cell;
      }
    }
    return bestMove;
  }

  int _minimaxTTT(int depth, bool isMax) {
    if (_findWinLine(2) != null) return 10 - depth;
    if (_findWinLine(1) != null) return depth - 10;
    final empties = _getEmptyCells();
    if (empties.isEmpty) return 0;

    int best = isMax ? -100 : 100;
    for (final cell in empties) {
      board[cell[0]][cell[1]] = isMax ? 2 : 1;
      final val = _minimaxTTT(depth + 1, !isMax);
      board[cell[0]][cell[1]] = 0;
      best = isMax ? math.max(best, val) : math.min(best, val);
    }
    return best;
  }

  // ─── Gomoku AI (Pattern scoring) ───────────────

  List<int>? _aiMoveGomoku() {
    if (_effectiveDifficulty == AiDifficulty.easy) {
      final win = _findThreat(2, 5);
      if (win != null) return win;
      return _randomNearPieces();
    }

    // Medium & Hard
    final win5 = _findThreat(2, 5);
    if (win5 != null) return win5;
    final block5 = _findThreat(1, 5);
    if (block5 != null) return block5;

    if (_effectiveDifficulty == AiDifficulty.hard) {
      final win4 = _findOpenThreat(2, 4);
      if (win4 != null) return win4;
      final block4 = _findOpenThreat(1, 4);
      if (block4 != null) return block4;
    }

    return _bestScoredMove();
  }

  int _countInDir(int r, int c, int dr, int dc, int player) {
    int count = 0;
    final n = gridSize;
    int nr = r + dr, nc = c + dc;
    while (nr >= 0 && nr < n && nc >= 0 && nc < n && board[nr][nc] == player) {
      count++;
      nr += dr;
      nc += dc;
    }
    return count;
  }

  int _countLine(int r, int c, int dr, int dc, int player) {
    return 1 + _countInDir(r, c, dr, dc, player) + _countInDir(r, c, -dr, -dc, player);
  }

  List<int>? _findThreat(int player, int len) {
    final n = gridSize;
    const dirs = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1],
    ];
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        if (board[r][c] != 0) continue;
        board[r][c] = player;
        for (final dir in dirs) {
          if (_countLine(r, c, dir[0], dir[1], player) >= len) {
            board[r][c] = 0;
            return [r, c];
          }
        }
        board[r][c] = 0;
      }
    }
    return null;
  }

  List<int>? _findOpenThreat(int player, int len) {
    final n = gridSize;
    const dirs = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1],
    ];
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        if (board[r][c] != 0) continue;
        board[r][c] = player;
        for (final dir in dirs) {
          final dr = dir[0], dc = dir[1];
          final count = _countLine(r, c, dr, dc, player);
          if (count >= len) {
            final backCount = _countInDir(r, c, -dr, -dc, player);
            final startR = r - backCount * dr;
            final startC = c - backCount * dc;
            final endR = startR + (count - 1) * dr;
            final endC = startC + (count - 1) * dc;
            final bR = startR - dr, bC = startC - dc;
            final aR = endR + dr, aC = endC + dc;
            final openBefore =
                bR >= 0 && bR < n && bC >= 0 && bC < n && board[bR][bC] == 0;
            final openAfter =
                aR >= 0 && aR < n && aC >= 0 && aC < n && board[aR][aC] == 0;
            if (openBefore || openAfter) {
              board[r][c] = 0;
              return [r, c];
            }
          }
        }
        board[r][c] = 0;
      }
    }
    return null;
  }

  int _scoreCell(int r, int c, int player) {
    int score = 0;
    const dirs = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1],
    ];
    board[r][c] = player;
    for (final dir in dirs) {
      final count = _countLine(r, c, dir[0], dir[1], player);
      score += switch (count) {
        >= 5 => 100000,
        4 => 10000,
        3 => 1000,
        2 => 100,
        _ => 10,
      };
    }
    board[r][c] = 0;
    return score;
  }

  List<int>? _bestScoredMove() {
    final candidates = _getCandidates();
    if (candidates.isEmpty) {
      final mid = gridSize ~/ 2;
      return [mid, mid];
    }

    double bestScore = -1;
    List<int> bestMove = candidates.first;
    for (final cell in candidates) {
      final aiScore = _scoreCell(cell[0], cell[1], 2).toDouble();
      final blockScore = _scoreCell(cell[0], cell[1], 1) * 1.1;
      final total = aiScore + blockScore;
      if (total > bestScore) {
        bestScore = total;
        bestMove = cell;
      }
    }
    return bestMove;
  }

  List<List<int>> _getCandidates() {
    final n = gridSize;
    final visited = List.generate(n, (_) => List.filled(n, false));
    final candidates = <List<int>>[];
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        if (board[r][c] == 0) continue;
        for (int dr = -2; dr <= 2; dr++) {
          for (int dc = -2; dc <= 2; dc++) {
            final nr = r + dr, nc = c + dc;
            if (nr >= 0 &&
                nr < n &&
                nc >= 0 &&
                nc < n &&
                board[nr][nc] == 0 &&
                !visited[nr][nc]) {
              candidates.add([nr, nc]);
              visited[nr][nc] = true;
            }
          }
        }
      }
    }
    return candidates;
  }

  List<int>? _randomNearPieces() {
    final candidates = _getCandidates();
    if (candidates.isEmpty) {
      final mid = gridSize ~/ 2;
      return [mid, mid];
    }
    return candidates[math.Random().nextInt(candidates.length)];
  }
}
