import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import 'package:radio_v2/core/theme/app_colors.dart';
import 'package:radio_v2/features/radio/presentation/providers/radio_providers.dart';
import 'package:radio_v2/features/weather_tab.dart';
import 'package:radio_v2/features/radio/presentation/widgets/radio_view.dart';
import 'package:radio_v2/features/horoscope/presentation/widgets/horoscope_view.dart';
import 'package:radio_v2/features/radio/presentation/widgets/mini_player.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    Widget mainContent;

    switch (_currentTab) {
      case 0:
        mainContent = const RadioView();
        break;
      case 1:
        mainContent = const WeatherTab();
        break;
      case 2:
        mainContent = const HoroscopeView();
        break;
      default:
        mainContent = const RadioView();
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _AppHeader(),
            const _MarqueeSection(),
            Expanded(child: mainContent),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(Icons.radio, "ЭФИР", 0),
                _navItem(Icons.cloud_queue, "ПОГОДА", 1),
                _navItem(Icons.auto_stories, "ГОРОСКОП", 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool active = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? AppColors.accent : Colors.white38),
          Text(
            label,
            style: TextStyle(
              color: active ? AppColors.accent : Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppHeader extends ConsumerWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greetingAsync = ref.watch(greetingProvider);

    final greeting = greetingAsync.when(
      data: (data) => data,
      loading: () => "ЗАГРУЗКА...",
      error: (_, _) => "ДОБРО ПОЖАЛОВАТЬ",
    );

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Text(
                "SakhaLive",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const CircleAvatar(
            backgroundColor: AppColors.cardBackground,
            child: Icon(Icons.person_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _MarqueeSection extends ConsumerWidget {
  const _MarqueeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marqueeText = ref.watch(marqueeTextProvider);
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Marquee(
        text: "SAKHALIVE  |  $marqueeText  ",
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
        velocity: 45,
        blankSpace: 100,
      ),
    );
  }
}
