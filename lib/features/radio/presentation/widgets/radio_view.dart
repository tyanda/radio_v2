import 'package:flutter/material.dart';
import 'package:sakha_live/features/radio/presentation/widgets/radio_cards_view.dart';

class RadioView extends StatelessWidget {
  const RadioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const RadioCardsView(),
    );
  }
}
