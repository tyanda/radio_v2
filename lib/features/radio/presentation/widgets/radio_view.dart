import 'package:flutter/material.dart';
import 'package:radio_v2/core/design/app_colors.dart';
import 'package:radio_v2/features/radio/presentation/widgets/radio_cards_view.dart';

class RadioView extends StatelessWidget {
  const RadioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const RadioCardsView(),
    );
  }
}
