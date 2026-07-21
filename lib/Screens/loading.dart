import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:safe_me/Resources/colors.dart';
import 'package:safe_me/Screens/Login/languageSelect.dart';
import 'package:safe_me/service/userService.dart';

import 'home_base.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  late final AnimationController _runController;
  late final Animation<double> _runProgress;

  @override
  void initState() {
    super.initState();
    _runController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );
    _runProgress = CurvedAnimation(
      parent: _runController,
      curve: Curves.easeInOut,
    );

    _runController.forward().whenComplete(() {
      if (mounted) {
        checkSession();
      }
    });
  }

  @override
  void dispose() {
    _runController.dispose();
    super.dispose();
  }

  Future<void> checkSession() async {
    final userSession = await _userService.checkSession();
    if (!mounted) return;

    if (userSession) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeBase()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SelectLanguage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appSurface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 20,
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.shield_outlined,
                        size: 72,
                        color: secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AnimatedBuilder(
                      animation: _runController,
                      builder: (context, child) {
                        return _RunToPoliceScene(
                          progress: _runProgress.value,
                          runPhase: _runController.value * 14,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _runProgress,
                    builder: (context, child) {
                      final reached = _runProgress.value >= 0.98;
                      return Text(
                        reached ? 'Welcome...' : 'Running to safety...',
                        style: TextStyle(
                          fontSize: 13,
                          color: appTextMuted,
                          fontFamily: 'Poppins-Light',
                          letterSpacing: 0.3,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  'Powered by Sri Lanka Police',
                  style: TextStyle(
                    fontSize: 13,
                    color: appTextSubtle,
                    fontFamily: 'Poppins-Light',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RunToPoliceScene extends StatelessWidget {
  const _RunToPoliceScene({
    required this.progress,
    required this.runPhase,
  });

  final double progress;
  final double runPhase;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 130,
          width: constraints.maxWidth,
          child: CustomPaint(
            painter: _RunToPolicePainter(
              progress: progress,
              runPhase: runPhase,
            ),
            size: Size(constraints.maxWidth, 130),
          ),
        );
      },
    );
  }
}

class _RunToPolicePainter extends CustomPainter {
  _RunToPolicePainter({
    required this.progress,
    required this.runPhase,
  });

  final double progress;
  final double runPhase;

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height * 0.82;
    const policeWidth = 52.0;
    const startX = 28.0;
    final endX = size.width - policeWidth - 16;
    final runnerX = startX + (endX - startX) * progress;
    final policeX = size.width - policeWidth - 8;

    _drawGround(canvas, size, groundY);
    _drawPolice(canvas, Offset(policeX, groundY));
    _drawRunner(
      canvas,
      Offset(runnerX, groundY),
      runPhase,
      progress < 0.98,
    );

    if (progress > 0.05 && progress < 0.95) {
      _drawMotionLines(canvas, Offset(runnerX - 18, groundY - 28));
    }
  }

  void _drawGround(Canvas canvas, Size size, double y) {
    final paint = Paint()
      ..color = appBorder
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(12, y), Offset(size.width - 12, y), paint);

    final dashPaint = Paint()
      ..color = appAccent.withValues(alpha: 0.35)
      ..strokeWidth = 1.5;

    for (var x = 20.0; x < size.width - 20; x += 18) {
      canvas.drawLine(Offset(x, y + 6), Offset(x + 8, y + 6), dashPaint);
    }
  }

  void _drawPolice(Canvas canvas, Offset base) {
    const h = 58.0;
    final bodyPaint = Paint()..color = secondary;
    final accentPaint = Paint()..color = appAccent;

    // Legs
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx + 14, base.dy - 18, 8, 18),
        const Radius.circular(4),
      ),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx + 28, base.dy - 18, 8, 18),
        const Radius.circular(4),
      ),
      bodyPaint,
    );

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx + 10, base.dy - h + 22, 32, 28),
        const Radius.circular(8),
      ),
      bodyPaint,
    );

    // Badge
    canvas.drawCircle(Offset(base.dx + 26, base.dy - h + 36), 7, accentPaint);
    canvas.drawCircle(
      Offset(base.dx + 26, base.dy - h + 36),
      7,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Head
    canvas.drawCircle(
      Offset(base.dx + 26, base.dy - h + 10),
      11,
      Paint()..color = const Color(0xFFFFCC80),
    );

    // Cap
    final capPath = Path()
      ..moveTo(base.dx + 14, base.dy - h + 8)
      ..lineTo(base.dx + 38, base.dy - h + 8)
      ..lineTo(base.dx + 36, base.dy - h + 2)
      ..lineTo(base.dx + 16, base.dy - h + 2)
      ..close();
    canvas.drawPath(capPath, bodyPaint);

    // Cap brim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx + 12, base.dy - h + 6, 28, 4),
        const Radius.circular(2),
      ),
      bodyPaint,
    );
  }

  void _drawRunner(Canvas canvas, Offset base, double phase, bool running) {
    final bob = running ? math.sin(phase) * 2.5 : 0.0;
    final y = base.dy + bob;
    const h = 50.0;

    final skinPaint = Paint()..color = const Color(0xFFFFCC80);
    final shirtPaint = Paint()..color = emergencyPrimary;
    final pantsPaint = Paint()..color = secondary;

    final legSwing = running ? math.sin(phase) * 0.55 : 0.0;

    // Back leg
    _drawLimb(
      canvas,
      Offset(base.dx + 14, y - 16),
      16,
      math.pi / 2 + legSwing,
      pantsPaint,
    );

    // Front leg
    _drawLimb(
      canvas,
      Offset(base.dx + 14, y - 16),
      16,
      math.pi / 2 - legSwing,
      pantsPaint,
    );

    // Torso
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(base.dx + 4, y - h + 18, 22, 24),
        const Radius.circular(6),
      ),
      shirtPaint,
    );

    // Arms
    final armSwing = running ? math.sin(phase + math.pi) * 0.7 : 0.0;
    _drawLimb(
      canvas,
      Offset(base.dx + 14, y - h + 28),
      14,
      -math.pi / 3 + armSwing,
      skinPaint,
    );
    _drawLimb(
      canvas,
      Offset(base.dx + 14, y - h + 28),
      14,
      -math.pi / 1.4 - armSwing,
      skinPaint,
    );

    // Head
    canvas.drawCircle(Offset(base.dx + 15, y - h + 8), 9, skinPaint);

    // Hair
    canvas.drawArc(
      Rect.fromCircle(center: Offset(base.dx + 15, y - h + 6), radius: 9),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFF4E342E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  void _drawLimb(
    Canvas canvas,
    Offset origin,
    double length,
    double angle,
    Paint paint,
  ) {
    paint.strokeWidth = 5;
    paint.strokeCap = StrokeCap.round;
    final end = Offset(
      origin.dx + math.cos(angle) * length,
      origin.dy + math.sin(angle) * length,
    );
    canvas.drawLine(origin, end, paint);
  }

  void _drawMotionLines(Canvas canvas, Offset origin) {
    final paint = Paint()
      ..color = appTextSubtle.withValues(alpha: 0.45)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final y = origin.dy + i * 8.0;
      canvas.drawLine(
        Offset(origin.dx - 10, y),
        Offset(origin.dx - 2, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RunToPolicePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.runPhase != runPhase;
  }
}
