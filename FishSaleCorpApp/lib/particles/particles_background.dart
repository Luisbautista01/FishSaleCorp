// ignore_for_file: unnecessary_import

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class ParticlesBackground extends StatefulWidget {
  final int numFish;
  final int numBubbles;
  final double speed;

  const ParticlesBackground({
    super.key,
    this.numFish = 40,
    this.numBubbles = 100,
    this.speed = 0.8,
  });

  @override
  State<ParticlesBackground> createState() => _ParticlesBackgroundState();
}

class _ParticlesBackgroundState extends State<ParticlesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Fish> _fishList;
  late List<_Bubble> _bubbleList;
  late List<_Plankton> _planktonList;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    final random = Random();
    final fishEmojis = ['🐟', '🐠', '🐡', '🦈', '🐬'];

    _fishList = List.generate(widget.numFish, (index) {
      final x = random.nextDouble();
      final y = random.nextDouble();
      final size = 18 + random.nextDouble() * 35;
      final direction = random.nextBool() ? 1.0 : -1.0;
      final speed = 0.4 + random.nextDouble() * 1.2;
      final emoji = fishEmojis[random.nextInt(fishEmojis.length)];
      final depth = 0.4 + random.nextDouble() * 0.6;
      return _Fish(x, y, size, direction, speed, emoji, depth);
    });

    _bubbleList = List.generate(widget.numBubbles, (index) {
      final x = random.nextDouble();
      final y = random.nextDouble();
      final radius = 1 + random.nextDouble() * 5;
      final speed = 0.2 + random.nextDouble() * 0.6;
      return _Bubble(x, y, radius, speed);
    });

    _planktonList = List.generate(120, (index) {
      final x = random.nextDouble();
      final y = random.nextDouble();
      final radius = 0.8 + random.nextDouble() * 1.8;
      final brightness = 0.3 + random.nextDouble() * 0.7;
      return _Plankton(x, y, radius, brightness);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _OceanPainter(
            _fishList,
            _bubbleList,
            _planktonList,
            _controller.value,
            isDark,
            widget.speed,
          ),
        );
      },
    );
  }
}

class _Fish {
  double x;
  double y;
  double size;
  double direction;
  double speed;
  String emoji;
  double depth;
  _Fish(
    this.x,
    this.y,
    this.size,
    this.direction,
    this.speed,
    this.emoji,
    this.depth,
  );
}

class _Bubble {
  double x;
  double y;
  double radius;
  double speed;
  _Bubble(this.x, this.y, this.radius, this.speed);
}

class _Plankton {
  double x;
  double y;
  double radius;
  double brightness;
  _Plankton(this.x, this.y, this.radius, this.brightness);
}

class _OceanPainter extends CustomPainter {
  final List<_Fish> fishList;
  final List<_Bubble> bubbleList;
  final List<_Plankton> planktonList;
  final double progress;
  final bool isDark;
  final double speed;

  _OceanPainter(
    this.fishList,
    this.bubbleList,
    this.planktonList,
    this.progress,
    this.isDark,
    this.speed,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final gradientShift = sin(progress * 2 * pi) * 0.1;
    final gradient = LinearGradient(
      colors: isDark
          ? [
              Color.lerp(
                Colors.teal.shade900,
                Colors.indigo.shade900,
                gradientShift.abs(),
              )!,
              Colors.black,
            ]
          : [
              Color.lerp(
                Colors.teal.shade200,
                Colors.cyan.shade400,
                gradientShift.abs(),
              )!,
              Colors.blue.shade900,
            ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final paintBackground = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paintBackground);

    final lightAngle = progress * 2 * pi;
    final lightX = size.width / 2 + sin(lightAngle) * 100;
    final lightPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [Colors.white.withOpacity(0.2), Colors.transparent],
            radius: 0.9,
          ).createShader(
            Rect.fromCircle(
              center: Offset(lightX, size.height * 0.1),
              radius: size.width * 0.9,
            ),
          )
      ..blendMode = BlendMode.softLight;
    canvas.drawRect(rect, lightPaint);

    final planktonPaint = Paint();
    for (final p in planktonList) {
      final dx =
          (p.x * size.width + sin(progress * 2 * pi + p.x) * 10) % size.width;
      final dy =
          size.height - ((p.y * size.height + progress * 50) % size.height);
      final glow = Paint()
        ..color = Colors.cyanAccent.withOpacity(p.brightness * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(dx, dy), p.radius * 2, glow);

      planktonPaint.color = Colors.white.withOpacity(p.brightness * 0.6);
      canvas.drawCircle(Offset(dx, dy), p.radius, planktonPaint);
    }

    final paintBubble = Paint()..color = Colors.white.withOpacity(0.45);
    for (final bubble in bubbleList) {
      final dx = bubble.x * size.width;
      final dy =
          size.height -
          ((bubble.y * size.height + progress * 600 * bubble.speed) %
              size.height);

      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(dx, dy), bubble.radius * 1.6, glowPaint);
      canvas.drawCircle(Offset(dx, dy), bubble.radius, paintBubble);
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (final fish in fishList) {
      final dx =
          (fish.x * size.width +
              progress * 250 * fish.direction * fish.speed * fish.depth) %
          size.width;
      final dy =
          (fish.y * size.height + sin(progress * 2 * pi + fish.x * 3) * 25) %
          size.height;

      canvas.save();
      if (fish.direction < 0) {
        canvas.translate(dx + fish.size / 2, dy);
        canvas.scale(-1, 1);
        canvas.translate(-fish.size / 2, 0);
      } else {
        canvas.translate(dx, dy);
      }

      final flicker = 0.7 + sin(progress * 4 * pi + fish.x) * 0.3;
      final fishText = TextSpan(
        text: fish.emoji,
        style: TextStyle(
          fontSize: fish.size,
          color: Colors.white.withOpacity(fish.depth * flicker),
          shadows: [
            Shadow(
              color: Colors.blueAccent.withOpacity(0.4),
              offset: const Offset(2, 2),
              blurRadius: 8,
            ),
          ],
        ),
      );

      textPainter.text = fishText;
      textPainter.layout();
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
