import 'package:flutter/material.dart';

class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;
  final ShimmerDirection direction;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.textStyle,
    this.borderRadius,
    this.direction = ShimmerDirection.ltr,
  });

  /// Создает shimmer-текст
  factory ShimmerWidget.text({
    required double width,
    required double height,
    TextStyle? textStyle,
    BorderRadius? borderRadius,
  }) {
    return ShimmerWidget(
      width: width,
      height: height,
      textStyle: textStyle,
      borderRadius: borderRadius,
    );
  }

  /// Создает shimmer-круг (для аватарок)
  factory ShimmerWidget.circle({
    required double size,
    BorderRadius? borderRadius,
  }) {
    return ShimmerWidget(
      width: size,
      height: size,
      borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
    );
  }

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment(-2.0 + _controller.value * 4, 0),
              end: const Alignment(-1.0, 0),
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.1),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

enum ShimmerDirection { ltr, rtl, ttb, btt }
