import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Виджет для scroll-driven анимации масштаба
/// Карточки в центре экрана имеют масштаб 1.0,
/// а уходящие за края плавно уменьшаются до 0.9
class ScrollScaleCard extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final double sensitivity;
  final VoidCallback? onTap;

  const ScrollScaleCard({
    super.key,
    required this.child,
    this.minScale = 0.90,
    this.maxScale = 1.0,
    this.sensitivity = 0.1,
    this.onTap,
  });

  @override
  State<ScrollScaleCard> createState() => _ScrollScaleCardState();
}

class _ScrollScaleCardState extends State<ScrollScaleCard> {
  final GlobalKey _boxKey = GlobalKey();
  double _scale = 1.0;
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attachToScroll();
      _updateScale();
    });
  }

  @override
  void dispose() {
    _detachFromScroll();
    super.dispose();
  }

  void _attachToScroll() {
    final context = _boxKey.currentContext;
    if (context == null) return;

    _scrollPosition = Scrollable.maybeOf(context)?.position;
    if (_scrollPosition != null) {
      _scrollPosition!.isScrollingNotifier.addListener(_onScroll);
    }
  }

  void _detachFromScroll() {
    if (_scrollPosition != null) {
      _scrollPosition!.isScrollingNotifier.removeListener(_onScroll);
      _scrollPosition = null;
    }
  }

  void _onScroll() {
    _updateScale();
  }

  void _updateScale() {
    final box = _boxKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final position = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final centerY = position.dy + box.size.height / 2;
    final screenCenterY = screenHeight / 2;
    final distanceFromCenter = (centerY - screenCenterY).abs();
    final maxDistance = screenHeight / 2;

    final normalizedDistance = (distanceFromCenter / maxDistance).clamp(0.0, 1.0);
    final scale = widget.maxScale - (normalizedDistance * widget.sensitivity);
    final clampedScale = scale.clamp(widget.minScale, widget.maxScale);

    if (mounted && (clampedScale - _scale).abs() > 0.005) {
      setState(() {
        _scale = clampedScale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(key: _boxKey, child: widget.child),
      ),
    );
  }
}
