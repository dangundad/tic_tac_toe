import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:tic_tac_toe/app/admob/ads_banner.dart';
import 'package:tic_tac_toe/app/admob/ads_helper.dart';
import 'package:tic_tac_toe/app/controllers/game_controller.dart';
import 'package:tic_tac_toe/app/data/enums/game_type.dart';
import 'package:tic_tac_toe/app/pages/game/widgets/board_painter.dart';

class GamePage extends GetView<GameController> {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Show result dialog when game ends
    ever(controller.phase, (phase) {
      if (phase == GamePhase.gameOver) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (Get.isDialogOpen != true) {
            _showResultDialog(cs);
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.gameType.value == GameType.tictactoe
                ? 'tic_tac_toe'.tr
                : 'gomoku'.tr,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.restartGame,
            tooltip: 'restart'.tr,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  _StatusBar(ctrl: controller),
                  SizedBox(height: 16.h),
                  Expanded(child: _BoardArea(ctrl: controller)),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
            BannerAdWidget(
              adUnitId: AdHelper.bannerAdUnitId,
              type: AdHelper.banner,
            ),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(ColorScheme cs) {
    final w = controller.winner.value;
    final isTTT = controller.gameType.value == GameType.tictactoe;
    final isVsAI = controller.isVsAI;

    String title;
    String subtitle;
    Color color;

    if (w == 1) {
      title = 'you_win'.tr;
      subtitle = isVsAI ? 'beat_ai'.tr : 'p1_wins'.tr;
      color = cs.primary;
    } else if (w == 2) {
      title = isVsAI ? 'ai_wins'.tr : 'p2_wins'.tr;
      subtitle = isVsAI ? 'try_again'.tr : 'well_played'.tr;
      color = cs.error;
    } else {
      title = 'draw'.tr;
      subtitle = 'close_game'.tr;
      color = cs.secondary;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              w == 1 ? '🎉' : w == 2 ? '😔' : '🤝',
              style: TextStyle(fontSize: 48.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14.sp, color: cs.onSurfaceVariant),
            ),
            SizedBox(height: 20.h),
            // Stats row
            _StatsRow(isTTT: isTTT),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(); // back to home
            },
            child: Text('home'.tr),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.restartGame();
            },
            child: Text('play_again'.tr),
          ),
        ],
      ),
    );
  }
}

// ─── Status Bar ───────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  final GameController ctrl;
  const _StatusBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTTT = ctrl.gameType.value == GameType.tictactoe;

    return Obx(() {
      final phase = ctrl.phase.value;
      final player = ctrl.currentPlayer.value;
      final isAI = ctrl.isVsAI;

      String text;
      Color bg;

      if (phase == GamePhase.idle) {
        text = 'ready'.tr;
        bg = cs.surfaceContainerHigh;
      } else if (phase == GamePhase.gameOver) {
        final w = ctrl.winner.value;
        text = w == 0
            ? 'draw'.tr
            : (w == 1
                ? 'you_win'.tr
                : (isAI ? 'ai_wins'.tr : 'p2_wins'.tr));
        bg = w == 1
            ? cs.primaryContainer
            : w == 2
            ? cs.errorContainer
            : cs.secondaryContainer;
      } else if (ctrl.isAiThinking.value) {
        text = 'ai_thinking'.tr;
        bg = cs.surfaceContainerHigh;
      } else {
        if (isAI) {
          text = player == 1 ? 'your_turn'.tr : 'ai_thinking'.tr;
        } else {
          text = player == 1
              ? (isTTT ? 'p1_turn_x'.tr : 'p1_turn_b'.tr)
              : (isTTT ? 'p2_turn_o'.tr : 'p2_turn_w'.tr);
        }
        bg = player == 1 ? cs.primaryContainer : cs.secondaryContainer;
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (ctrl.isAiThinking.value)
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: SizedBox(
                  width: 16.r,
                  height: 16.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Board Area ───────────────────────────────────────────

class _BoardArea extends StatelessWidget {
  final GameController ctrl;
  const _BoardArea({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTTT = ctrl.gameType.value == GameType.tictactoe;
    final isVsAI = ctrl.isVsAI;

    // Colors
    final p1Color = cs.primary; // X or Black
    final p2Color = isVsAI
        ? cs.error
        : cs.secondary; // O or White (AI is red in vs AI)
    final gridColor = cs.outlineVariant;
    final bgColor = isTTT
        ? cs.surfaceContainerLow
        : const Color(0xFFDEB887); // Burlywood for Gomoku

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Obx(() {
            return GestureDetector(
              onTapDown: (details) {
                if (!ctrl.isPlaying) return;
                if (ctrl.isAiThinking.value) return;
                if (isVsAI && ctrl.currentPlayer.value == 2) return;

                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final localPos = box.globalToLocal(details.globalPosition);
                final size = box.size;
                final n = ctrl.gridSize;
                final col = (localPos.dx / size.width * n).floor();
                final row = (localPos.dy / size.height * n).floor();
                if (row >= 0 && row < n && col >= 0 && col < n) {
                  ctrl.placePiece(row, col);
                }
              },
              child: CustomPaint(
                painter: BoardPainter(
                  board: ctrl.board,
                  gameType: ctrl.gameType.value,
                  winLine: ctrl.winLine.value,
                  winProgress: ctrl.winProgress.value,
                  lastPlaced: ctrl.lastPlaced.value,
                  p1Color: p1Color,
                  p2Color: p2Color,
                  gridColor: gridColor,
                  bgColor: bgColor,
                ),
                child: const SizedBox.expand(),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Stats Row in Dialog ──────────────────────────────────

class _StatsRow extends StatelessWidget {
  final bool isTTT;
  const _StatsRow({required this.isTTT});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ctrl = GameController.to;

    return Obx(() {
      final w = isTTT ? ctrl.tttWins.value : ctrl.goWins.value;
      final l = isTTT ? ctrl.tttLosses.value : ctrl.goLosses.value;
      final d = isTTT ? ctrl.tttDraws.value : ctrl.goDraws.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatChip(label: 'wins'.tr, value: w, color: cs.primary),
          _StatChip(label: 'draws'.tr, value: d, color: cs.secondary),
          _StatChip(label: 'losses'.tr, value: l, color: cs.error),
        ],
      );
    });
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: color.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}
