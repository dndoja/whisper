import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

final _renderer = TextPaint(
  style: const TextStyle(
    fontSize: 16,
    color: Colors.white,
  ),
);

final _rendererStatus = TextPaint(
  style: const TextStyle(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    color: Colors.white,
  ),
);
final _rendererYell = TextPaint(
  style: const TextStyle(
    fontSize: 16,
    color: Colors.red,
    fontWeight: FontWeight.bold,
  ),
);

class TextBubble extends TextBoxComponent {
  TextBubble(
    String text, {
    required Vector2 position,
    this.yell = false,
    this.status = false,
    Function()? onComplete,
  }) : super(
          anchor: Anchor.topCenter,
          text: text,
          textRenderer: yell
              ? _rendererYell
              : status
                  ? _rendererStatus
                  : _renderer,
          position: position,
          onComplete: onComplete,
          scale: Vector2.all(0.3),
          boxConfig: const TextBoxConfig(
            dismissDelay: 2,
            margins: EdgeInsets.all(16),
            timePerChar: 0.05,
          ),
        );

  final bool status;
  final bool yell;
  late final bgPaint = Paint()
    ..color = status ? Colors.deepPurple : Colors.black.withOpacity(0.7);
  late final borderPaint = Paint()
    ..color = yell ? Colors.red : const Color(0xFFFFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  @override
  void render(Canvas canvas) {
    if (status) {
      final Rect rect = Rect.fromLTRB(0, 0, width, height);
      canvas.drawRect(rect, bgPaint);
      canvas.drawRect(rect, borderPaint);
      super.render(canvas);
      return;
    }

    const triangleHeight = 5.0;
    final RRect rect = RRect.fromLTRBR(
      0,
      0,
      width,
      height - triangleHeight,
      const Radius.circular(16),
    );

    final p1 = Path()..addRRect(rect);
    final p2 = Path()
      ..addPolygon(
        [
          Offset(width / 2 - 5, height - triangleHeight),
          Offset(width / 2 + 8, height - triangleHeight),
          Offset(width / 2 + 2, height + triangleHeight),
        ],
        true,
      );
    final path = Path.combine(PathOperation.union, p1, p2);

    canvas.drawPath(path, bgPaint);
    canvas.drawPath(path, borderPaint);
    super.render(canvas);
  }
}
