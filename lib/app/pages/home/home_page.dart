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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: Text('app_name'.tr)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'game_type'.tr,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _GameTypeSelector(ctrl: controller),
                    SizedBox(height: 24.h),
                    Text(
                      'game_mode'.tr,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _GameModeSelector(ctrl: controller),
                    SizedBox(height: 24.h),
                    Obx(() {
                      if (controller.gameMode.value != GameMode.vsAI) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'difficulty'.tr,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurfaceVariant,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          _DifficultySelector(ctrl: controller),
                          SizedBox(height: 24.h),
                        ],
                      );
                    }),
                    Text(
                      'stats'.tr,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _StatsCards(ctrl: controller),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: FilledButton(
                        onPressed: controller.startGame,
                        child: Text(
                          'start_game'.tr,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
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

class _GameTypeSelector extends StatelessWidget {
  final GameController ctrl;
  const _GameTypeSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          _OptionCard(
            label: 'tic_tac_toe'.tr,
            icon: '✕',
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
      );
    });
  }
}

class _GameModeSelector extends StatelessWidget {
  final GameController ctrl;
  const _GameModeSelector({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
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
      );
    });
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
                  _BigStat(value: wins, label: 'wins'.tr, color: cs.primary),
                  Container(width: 1, height: 40.h, color: cs.outlineVariant),
                  _BigStat(value: draws, label: 'draws'.tr, color: cs.secondary),
                  Container(width: 1, height: 40.h, color: cs.outlineVariant),
                  _BigStat(value: losses, label: 'losses'.tr, color: cs.error),
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

class _BigStat extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  const _BigStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24.sp,
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

class _OptionCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isSelected ? cs.primaryContainer : cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? cs.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(icon, style: TextStyle(fontSize: 24.sp)),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? cs.primary : cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
