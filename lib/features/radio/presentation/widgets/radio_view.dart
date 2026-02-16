import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radio_v2/features/radio/presentation/widgets/radio_cards_view.dart';

class RadioView extends ConsumerWidget {
  const RadioView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const RadioCardsView();
  }
}
