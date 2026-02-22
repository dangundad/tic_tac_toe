import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tic_tac_toe/app/data/enums/game_type.dart';

class BoardPainter extends CustomPainter {
  final List<List<int>> board;
  final GameType gameType;
  final List<int>? winLine;
  final double winProgress;
  final List<int>? lastPlaced;
  final Color p1Color;
  final Color p2Color;
  final Color gridColor;
  final Color bgColor;

  BoardPainter({
    required this.board,
    required this.gameType,
    required this.p1Color,
    required this.p2Color,
    required this.gridColor,
    required this.bgColor,
    this.winLine,
    this.winProgress = 0,
    this.lastPlaced,
  });

  bool get isTTT => gameType == GameType.tictactoe;
  int get n => board.length;

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / n;
    final cellH = size.height / n;

    _drawBackground(canvas, size);
    _drawGrid(canvas, size, cellW, cellH);
    _drawPieces(canvas, cellW, cellH);
    if (winLine != null && winProgress > 0) {
      _drawWinLine(canvas, size, cellW, cellH);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
      Paint()..color = bgColor,
    );
  }

  void _drawGrid(Canvas canvas, Size size, double cellW, double cellH) {
    final paint =
        Paint()
          ..color = gridColor
          ..strokeWidth = isTTT ? 3 : 1
          ..strokeCap = StrokeCap.round;

    if (isTTT) {
      // Only inner lines for TTT (2 vertical, 2 horizontal)
      for (int i = 1; i < n; i++) {
        final x = i * cellW;
        final y = i * cellH;
        canvas.drawLine(Offset(x, 8), Offset(x, size.height - 8), paint);
        canvas.drawLine(Offset(8, y), Offset(size.width - 8, y), paint);
      }
    } else {
      // Full grid for Gomoku (lines through center of cells)
      for (int i = 0; i < n; i++) {
        final x = (i + 0.5) * cellW;
        final y = (i + 0.5) * cellH;
        canvas.drawLine(
          Offset(x, cellH * 0.5),
          Offset(x, size.height - cellH * 0.5),
          paint,
        );
        canvas.drawLine(
          Offset(cellW * 0.5, y),
          Offset(size.width - cellW * 0.5, y),
          paint,
        );
      }
      // Star points (Gomoku standard: center + 4 corners of inner grid)
      _drawStarPoints(canvas, cellW, cellH);
    }
  }

  void _drawStarPoints(Canvas canvas, double cellW, double cellH) {
    final pts = <List<int>>[
      [7, 7],
      [3, 3],
      [3, 11],
      [11, 3],
      [11, 11],
    ];
    final paint = Paint()..color = gridColor;
    for (final pt in pts) {
      final x = (pt[1] + 0.5) * cellW;
      final y = (pt[0] + 0.5) * cellH;
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  void _drawPieces(Canvas canvas, double cellW, double cellH) {
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        final v = board[r][c];
        if (v == 0) continue;
        final cx = (c + 0.5) * cellW;
        final cy = (r + 0.5) * cellH;
        final color = v == 1 ? p1Color : p2Color;

        if (isTTT) {
          _drawTTTPiece(canvas, cx, cy, cellW, cellH, v, color);
        } else {
          _drawGomokuPiece(canvas, cx, cy, cellW, v, color);
        }
      }
    }
  }

  void _drawTTTPiece(
    Canvas canvas,
    double cx,
    double cy,
    double cellW,
    double cellH,
    int v,
    Color color,
  ) {
    final r = math.min(cellW, cellH) * 0.32;
    if (v == 1) {
      // X - two crossing lines
      final paint =
          Paint()
            ..color = color
            ..strokeWidth = cellW * 0.08
            ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx - r, cy - r),
        Offset(cx + r, cy + r),
        paint,
      );
      canvas.drawLine(
        Offset(cx + r, cy - r),
        Offset(cx - r, cy + r),
        paint,
      );
    } else {
      // O - circle
      final paint =
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = cellW * 0.08;
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  void _drawGomokuPiece(
    Canvas canvas,
    double cx,
    double cy,
    double cellW,
    int v,
    Color color,
  ) {
    final r = cellW * 0.42;

    if (v == 1) {
      // Black stone with radial gradient feel
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()..color = Colors.black.withValues(alpha: 0.15),
      );
      canvas.drawCircle(Offset(cx, cy), r - 1, Paint()..color = color);
      // Highlight
      canvas.drawCircle(
        Offset(cx - r * 0.3, cy - r * 0.3),
        r * 0.25,
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      );
    } else {
      // White stone with border
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()..color = Colors.black.withValues(alpha: 0.2),
      );
      canvas.drawCircle(Offset(cx, cy), r - 1, Paint()..color = color);
      canvas.drawCircle(
        Offset(cx, cy),
        r - 1,
        Paint()
          ..color = Colors.grey.shade400
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      canvas.drawCircle(
        Offset(cx - r * 0.3, cy - r * 0.3),
        r * 0.25,
        Paint()..color = Colors.white.withValues(alpha: 0.5),
      );
    }
  }

  void _drawWinLine(Canvas canvas, Size size, double cellW, double cellH) {
    final line = winLine!;
    final x1 = (line[1] + 0.5) * cellW;
    final y1 = (line[0] + 0.5) * cellH;
    final x2 = (line[3] + 0.5) * cellW;
    final y2 = (line[2] + 0.5) * cellH;

    final xEnd = x1 + (x2 - x1) * winProgress;
    final yEnd = y1 + (y2 - y1) * winProgress;

    // Glow
    canvas.drawLine(
      Offset(x1, y1),
      Offset(xEnd, yEnd),
      Paint()
        ..color = Colors.yellow.withValues(alpha: 0.5)
        ..strokeWidth = isTTT ? 16 : 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // Line
    canvas.drawLine(
      Offset(x1, y1),
      Offset(xEnd, yEnd),
      Paint()
        ..color = Colors.yellow
        ..strokeWidth = isTTT ? 8 : 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(BoardPainter old) =>
      old.board != board ||
      old.winProgress != winProgress ||
      old.winLine != winLine ||
      old.lastPlaced != lastPlaced;
}
