import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';

import '../../core/providers/radio_providers.dart';

/// Общий виджет бегущей строки
/// Используется на всех основных экранах
class MarqueeSection extends ConsumerWidget {
  const MarqueeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marqueeText = ref.watch(marqueeTextProvider);
    return Container(
      height: 32.0,
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      alignment: Alignment.center,
      child: Marquee(
        text:
            "SAKHALIVE  |  ${marqueeText.toUpperCase()}  |  ОСТАВАЙТЕСЬ С НАМИ  ",
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: Colors.black,
        ),
        velocity: 30,
        blankSpace: 100,
      ),
    );
  }
}
