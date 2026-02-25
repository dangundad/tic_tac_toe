import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:tic_tac_toe/app/admob/ads_banner.dart';
import 'package:tic_tac_toe/app/admob/ads_helper.dart';
import 'package:tic_tac_toe/app/controllers/game_controller.dart';
import 'package:tic_tac_toe/app/data/enums/ai_difficulty.dart';
import 'package:tic_tac_toe/app/data/enums/game_mode.dart';
import 'package:tic_tac_toe/app/data/enums/game_type.dart';

class HomePage extends GetView<GameController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _HomePageContent(controller: controller);
  }
}

class _HomePageContent extends StatefulWidget {
  final GameController controller;

  const _HomePageContent({required this.controller});

  @override
  State<_HomePageContent> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePageContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final Animation<double> _bgPulse;
  static const _sections = 5;
  late final List<Animation<double>> _fade;
  late final List<Animation<Offset>> _slide;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _bgPulse = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut),
    );

    _fade = List.generate(_sections, (i) {
      final start = 0.12 + i * 0.12;
      final end = (start + 0.3).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
    _slide = List.generate(_sections, (i) {
      final start = 0.12 + i * 0.12;
      final end = (start + 0.3).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Widget _staggered(int index, Widget child) {
    return FadeTransition(
      opacity: _fade[index],
      child: SlideTransition(position: _slide[index], child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final controller = widget.controller;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primary.withValues(alpha: 0.12),
              cs.surface,
              cs.secondaryContainer.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.r),
                child: ScaleTransition(
                  scale: _bgPulse,
                  child: _Header(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _staggered(0, const _SectionLabel(label: 'game_type')),
                      SizedBox(height: 10.h),
                      _staggered(0, _GameTypeSelector(ctrl: controller)),
                      SizedBox(height: 24.h),
                      _staggered(1, const _SectionLabel(label: 'game_mode')),
                      SizedBox(height: 10.h),
                      _staggered(1, _GameModeSelector(ctrl: controller)),
                      SizedBox(height: 24.h),
                      _staggered(
                        2,
                        Obx(() {
                          if (controller.gameMode.value != GameMode.vsAI) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SectionLabel(label: 'difficulty'),
                              SizedBox(height: 10.h),
                              _DifficultySelector(ctrl: controller),
                              SizedBox(height: 24.h),
                            ],
                          );
                        }),
                      ),
                      _staggered(3, const _SectionLabel(label: 'stats')),
                      SizedBox(height: 10.h),
                      _staggered(3, _StatsCards(ctrl: controller)),
                      SizedBox(height: 32.h),
                      _staggered(4, _GradientStartButton(ctrl: controller)),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
              Container(
                color: cs.surface.withValues(alpha: 0.9),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 12.w,
                      right: 12.w,
                      top: 8.h,
                      bottom: 10.h,
                    ),
                    child: BannerAdWidget(
                      adUnitId: AdHelper.bannerAdUnitId,
                      type: AdHelper.banner,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer,
            cs.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: cs.outline.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Text('❌', style: TextStyle(fontSize: 30.sp)),
          SizedBox(width: 10.w),
          Text(
            'app_name'.tr,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w900,
              color: cs.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientStartButton extends StatefulWidget {
  final GameController ctrl;
  const _GradientStartButton({required this.ctrl});

  @override
  State<_GradientStartButton> createState() => _GradientStartButtonState();
}

class _GradientStartButtonState extends State<_GradientStartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.ctrl.startGame();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.tertiary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('▶', style: TextStyle(fontSize: 18.sp, color: cs.onPrimary)),
                SizedBox(width: 10.w),
                Text(
                  'start_game'.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: cs.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      label.tr,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: cs.onSurfaceVariant,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _GameTypeSelector extends StatelessWidget {
  final GameController ctrl;
  const _GameTypeSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      children: [
        _OptionCard(
          label: 'tic_tac_toe'.tr,
          icon: '❌',
          isSelected: ctrl.gameType.value == GameType.tictactoe,
          onTap: () => ctrl.gameType.value = GameType.tictactoe,
        ),
        SizedBox(width: 12.w),
        _OptionCard(
          label: 'gomoku'.tr,
          icon: '⚫',
          isSelected: ctrl.gameType.value == GameType.gomoku,
          onTap: () => ctrl.gameType.value = GameType.gomoku,
        ),
      ],
    ));
  }
}

class _GameModeSelector extends StatelessWidget {
  final GameController ctrl;
  const _GameModeSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      children: [
        _OptionCard(
          label: 'vs_ai'.tr,
          icon: '🤖',
          isSelected: ctrl.gameMode.value == GameMode.vsAI,
          onTap: () => ctrl.gameMode.value = GameMode.vsAI,
        ),
        SizedBox(width: 12.w),
        _OptionCard(
          label: 'vs_friend'.tr,
          icon: '👥',
          isSelected: ctrl.gameMode.value == GameMode.vsFriend,
          onTap: () => ctrl.gameMode.value = GameMode.vsFriend,
        ),
      ],
    ));
  }
}

class _DifficultySelector extends StatelessWidget {
  final GameController ctrl;
  const _DifficultySelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      return Row(
        children: [
          _DiffChip(
            label: 'easy'.tr,
            isSelected: ctrl.difficulty.value == AiDifficulty.easy,
            color: Colors.green,
            onTap: () => ctrl.difficulty.value = AiDifficulty.easy,
          ),
          SizedBox(width: 8.w),
          _DiffChip(
            label: 'medium'.tr,
            isSelected: ctrl.difficulty.value == AiDifficulty.medium,
            color: cs.secondary,
            onTap: () => ctrl.difficulty.value = AiDifficulty.medium,
          ),
          SizedBox(width: 8.w),
          _DiffChip(
            label: 'hard'.tr,
            isSelected: ctrl.difficulty.value == AiDifficulty.hard,
            color: cs.error,
            onTap: () => ctrl.difficulty.value = AiDifficulty.hard,
          ),
        ],
      );
    });
  }
}

class _DiffChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _DiffChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? color : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsCards extends StatelessWidget {
  final GameController ctrl;
  const _StatsCards({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      final isTTT = ctrl.gameType.value == GameType.tictactoe;
      final wins = isTTT ? ctrl.tttWins.value : ctrl.goWins.value;
      final losses = isTTT ? ctrl.tttLosses.value : ctrl.goLosses.value;
      final draws = isTTT ? ctrl.tttDraws.value : ctrl.goDraws.value;
      final total = wins + losses + draws;
      final winRate = total == 0 ? 0.0 : wins / total;

      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AnimatedStatNumber(value: wins, label: 'wins'.tr, color: cs.primary),
                  Container(width: 1, height: 40.h, color: cs.outlineVariant),
                  _AnimatedStatNumber(value: draws, label: 'draws'.tr, color: cs.secondary),
                  Container(width: 1, height: 40.h, color: cs.outlineVariant),
                  _AnimatedStatNumber(value: losses, label: 'losses'.tr, color: cs.error),
                ],
              ),
              SizedBox(height: 12.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: winRate,
                  minHeight: 6.h,
                  backgroundColor: cs.errorContainer,
                  valueColor: AlwaysStoppedAnimation(cs.primary),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                total == 0
                    ? 'no_games_yet'.tr
                    : '${'win_rate'.tr}: ${(winRate * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 12.sp, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _AnimatedStatNumber extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _AnimatedStatNumber({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) {
            return ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            );
          },
          child: Text(
            '$value',
            key: ValueKey(value),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: color,
            ),
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

class _OptionCard extends StatefulWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(vertical: 18.h),
            decoration: BoxDecoration(
              gradient: widget.isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cs.primaryContainer,
                        cs.secondaryContainer.withValues(alpha: 0.7),
                      ],
                    )
                  : LinearGradient(
                      colors: [cs.surfaceContainerHigh, cs.surfaceContainerHigh],
                    ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: widget.isSelected
                    ? cs.primary
                    : cs.outline.withValues(alpha: 0.2),
                width: widget.isSelected ? 2 : 1,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 1,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: cs.shadow.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              children: [
                AnimatedScale(
                  scale: widget.isSelected ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    widget.icon,
                    style: TextStyle(fontSize: 26.sp),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight:
                        widget.isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: widget.isSelected ? cs.primary : cs.onSurface,
                  ),
                ),
                if (widget.isSelected) ...[
                  SizedBox(height: 4.h),
                  Container(
                    width: 24.w,
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
