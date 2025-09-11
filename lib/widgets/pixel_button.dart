import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PixelButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLarge;
  final IconData? icon;

  const PixelButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLarge = false,
    this.icon,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        decoration: BoxDecoration(
          color: AppColors.pixelBlack,
          border: Border.all(
            color: _isPressed ? AppColors.pixelGray : AppColors.pixelWhite,
            width: 3,
          ),
          boxShadow: _isPressed
              ? []
              : [
                  const BoxShadow(
                    color: AppColors.pixelGray,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isLarge ? 24 : 16,
          vertical: widget.isLarge ? 16 : 8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: AppColors.pixelWhite,
                size: widget.isLarge ? 16 : 12,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              widget.text,
              style: TextStyle(
                color: AppColors.pixelWhite,
                fontSize: widget.isLarge ? 14 : 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                shadows: const [
                  Shadow(
                    offset: Offset(1, 1),
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}