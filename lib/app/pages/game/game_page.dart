import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:tic_tac_toe/app/admob/ads_banner.dart';
import 'package:tic_tac_toe/app/admob/ads_helper.dart';
import 'package:tic_tac_toe/app/controllers/game_controller.dart';
import 'package:tic_tac_toe/app/data/enums/game_type.dart';
import 'package:tic_tac_toe/app/pages/game/widgets/board_painter.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  // Entrance animation for status bar + board
  late AnimationController _entranceCtrl;
  late Animation<double> _statusFade;
  late Animation<Offset> _statusSlide;
  late Animation<double> _boardScale;
  late Animation<double> _boardFade;

  // Win pulse animation
  late AnimationController _pulseCtrl;

  Worker? _phaseWorker;
  Worker? _winnerWorker;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _statusFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _statusSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _boardScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );
    _boardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _entranceCtrl.forward();

    final ctrl = Get.find<GameController>();

    _phaseWorker = ever(ctrl.phase, (phase) {
      if (phase == GamePhase.gameOver) {
        // Start pulsing when game ends
        _pulseCtrl.repeat(reverse: true);
        Future.delayed(const Duration(milliseconds: 800), () {
          if (Get.isDialogOpen != true) {
            _showResultDialog();
          }
        });
      } else {
        _pulseCtrl.stop();
        _pulseCtrl.reset();
      }
    });
  }

  @override
  void dispose() {
    _phaseWorker?.dispose();
    _winnerWorker?.dispose();
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _showResultDialog() {
    final ctrl = Get.find<GameController>();
    final cs = Theme.of(context).colorScheme;

    final w = ctrl.winner.value;
    final isTTT = ctrl.gameType.value == GameType.tictactoe;
    final isVsAI = ctrl.isVsAI;

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
      _ResultDialog(
        emoji: w == 1 ? '🎉' : w == 2 ? '😔' : '🤝',
        title: title,
        subtitle: subtitle,
        titleColor: color,
        isTTT: isTTT,
        onPlayAgain: () {
          Get.back();
          ctrl.restartGame();
        },
        onHome: () {
          Get.back();
          Get.back();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ctrl = Get.find<GameController>();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Obx(
          () => Text(
            ctrl.gameType.value == GameType.tictactoe
                ? 'tic_tac_toe'.tr
                : 'gomoku'.tr,
          ),
        ),
        actions: [
          _AnimatedIconButton(
            icon: Icons.refresh_rounded,
            tooltip: 'restart'.tr,
            onTap: () {
              _pulseCtrl.stop();
              _pulseCtrl.reset();
              ctrl.restartGame();
            },
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
                  // Status bar entrance
                  FadeTransition(
                    opacity: _statusFade,
                    child: SlideTransition(
                      position: _statusSlide,
                      child: _StatusBar(ctrl: ctrl),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Board entrance
                  Expanded(
                    child: FadeTransition(
                      opacity: _boardFade,
                      child: ScaleTransition(
                        scale: _boardScale,
                        child: _BoardArea(
                          ctrl: ctrl,
                          pulseCtrl: _pulseCtrl,
                        ),
                      ),
                    ),
                  ),
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
}

// ─── Animated Icon Button ─────────────────────────────────

class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _AnimatedIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _rotAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotAnim,
      child: IconButton(
        icon: Icon(widget.icon),
        onPressed: () {
          _ctrl.forward(from: 0);
          widget.onTap();
        },
        tooltip: widget.tooltip,
      ),
    );
  }
}

// ─── Result Dialog ────────────────────────────────────────

class _ResultDialog extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color titleColor;
  final bool isTTT;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const _ResultDialog({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.isTTT,
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  State<_ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<_ResultDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _emojiScale;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _emojiScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
      ),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
      ),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _emojiScale,
            child: Text(
              widget.emoji,
              style: TextStyle(fontSize: 48.sp),
            ),
          ),
          SizedBox(height: 8.h),
          FadeTransition(
            opacity: _contentFade,
            child: SlideTransition(
              position: _contentSlide,
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: widget.titleColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _StatsRow(isTTT: widget.isTTT),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onHome,
          child: Text('home'.tr),
        ),
        FilledButton(
          onPressed: widget.onPlayAgain,
          child: Text('play_again'.tr),
        ),
      ],
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                text,
                key: ValueKey(text),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
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
  final AnimationController pulseCtrl;
  const _BoardArea({required this.ctrl, required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTTT = ctrl.gameType.value == GameType.tictactoe;
    final isVsAI = ctrl.isVsAI;

    final p1Color = cs.primary;
    final p2Color = isVsAI ? cs.error : cs.secondary;
    final gridColor = cs.outlineVariant;
    final bgColor = isTTT
        ? cs.surfaceContainerLow
        : const Color(0xFFDEB887);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Obx(() {
            // Win glow pulse overlay
            final isGameOver = ctrl.phase.value == GamePhase.gameOver;
            final hasWinner = ctrl.winner.value != 0;

            return AnimatedBuilder(
              animation: pulseCtrl,
              builder: (context, child) {
                // Pulse the board container when there's a winner
                final pulse = isGameOver && hasWinner
                    ? pulseCtrl.value
                    : 0.0;

                final winnerColor = ctrl.winner.value == 1
                    ? p1Color
                    : ctrl.winner.value == 2
                    ? p2Color
                    : Colors.transparent;

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: pulse > 0
                        ? [
                            BoxShadow(
                              color: winnerColor.withValues(
                                alpha: 0.45 * pulse,
                              ),
                              blurRadius: 24 + 12 * pulse,
                              spreadRadius: 4 * pulse,
                            ),
                          ]
                        : [],
                  ),
                  child: child,
                );
              },
              child: GestureDetector(
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
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Text(
            '$value',
            key: ValueKey(value),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: color.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
