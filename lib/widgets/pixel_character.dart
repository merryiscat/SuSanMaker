import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PixelCharacter extends StatefulWidget {
  final bool isWalking;

  const PixelCharacter({
    super.key,
    this.isWalking = true,
  });

  @override
  State<PixelCharacter> createState() => _PixelCharacterState();
}

class _PixelCharacterState extends State<PixelCharacter>
    with TickerProviderStateMixin {
  late AnimationController _walkController;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    if (widget.isWalking) {
      _walkController.repeat();
      _bounceController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _walkController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_walkController, _bounceController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceController.value * 4),
          child: SizedBox(
            width: 64,
            height: 80,
            child: CustomPaint(
              painter: PixelCharacterPainter(
                frame: (_walkController.value * 4).floor(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PixelCharacterPainter extends CustomPainter {
  final int frame;

  PixelCharacterPainter({required this.frame});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final pixelSize = size.width / 16; // 16x20 픽셀 캐릭터

    // 간단한 픽셀 캐릭터 그리기
    _drawPixelRect(canvas, paint, 6, 2, 4, 2, Colors.brown, pixelSize); // 머리
    _drawPixelRect(canvas, paint, 7, 4, 2, 1, Colors.pink, pixelSize); // 얼굴
    _drawPixelRect(canvas, paint, 5, 6, 6, 4, Colors.blue, pixelSize); // 몸통
    
    // 걷는 애니메이션을 위한 다리 위치 변경
    if (frame % 2 == 0) {
      _drawPixelRect(canvas, paint, 6, 10, 2, 6, Colors.brown, pixelSize); // 왼쪽 다리
      _drawPixelRect(canvas, paint, 8, 11, 2, 5, Colors.brown, pixelSize); // 오른쪽 다리
    } else {
      _drawPixelRect(canvas, paint, 6, 11, 2, 5, Colors.brown, pixelSize); // 왼쪽 다리
      _drawPixelRect(canvas, paint, 8, 10, 2, 6, Colors.brown, pixelSize); // 오른쪽 다리
    }
    
    _drawPixelRect(canvas, paint, 4, 7, 2, 3, Colors.orange, pixelSize); // 왼팔
    _drawPixelRect(canvas, paint, 10, 7, 2, 3, Colors.orange, pixelSize); // 오른팔
  }

  void _drawPixelRect(Canvas canvas, Paint paint, int x, int y, int width, int height, Color color, double pixelSize) {
    paint.color = color;
    canvas.drawRect(
      Rect.fromLTWH(
        x * pixelSize,
        y * pixelSize,
        width * pixelSize,
        height * pixelSize,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}