import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design/design.dart';
import '../../../../core/providers.dart';
import '../presentation/providers/charts_provider.dart';
import '../data/models/chart_item.dart';
import 'widgets/chart_item_tile.dart';
import 'widgets/video_ad_card.dart';

/// Экран "Топ Чарт" с музыкальными хитами и видео-рекламой
class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(
      themeProvider.select((s) => s.value?.isDarkTheme ?? true),
    );
    final theme = Theme.of(context);
    final chartsAsync = ref.watch(chartsProvider);
    final currentSource = ref.watch(chartSourceProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.background
          : AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(chartsProvider.notifier).refresh(),
          child: _buildChartsTab(
            chartsAsync,
            theme,
            isDark,
            ref,
            context,
            currentSource,
          ),
        ),
      ),
    );
  }

  Widget _buildChartsTab(
    AsyncValue<List<ChartItem>> chartsAsync,
    ThemeData theme,
    bool isDark,
    WidgetRef ref,
    BuildContext context,
    ChartSource currentSource,
  ) {
    return chartsAsync.when(
      data: (charts) {
        final currentCategory = ref.watch(chartCategoryProvider);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            100, // Padding для нижней навигации
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и селектор
              Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.xs,
                  bottom: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Топ Чарт',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? AppColors.textPrimary
                                    : AppColors.textName,
                                letterSpacing: -0.5,
                              ),
                            ),
                            // Переключатель источника
                            SizedBox(height: 4),
                            Row(
                              children: [
                                _buildSourceButton(
                                  ref,
                                  '🍎 iTunes',
                                  ChartSource.itunes,
                                  currentSource == ChartSource.itunes,
                                  isDark,
                                ),
                                SizedBox(width: 8),
                                _buildSourceButton(
                                  ref,
                                  '🎵 Deezer',
                                  ChartSource.deezer,
                                  currentSource == ChartSource.deezer,
                                  isDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Селектор категорий
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardBackground
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              _buildCategoryButton(
                                context,
                                ref,
                                'РУССКОЕ',
                                ChartCategory.russian,
                                currentCategory == ChartCategory.russian,
                                isDark,
                              ),
                              _buildCategoryButton(
                                context,
                                ref,
                                'ЗАРУБЕЖНОЕ',
                                ChartCategory.international,
                                currentCategory == ChartCategory.international,
                                isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      currentCategory == ChartCategory.russian
                          ? 'Топ 10 русских хитов по версии iTunes'
                          : 'Топ 10 зарубежных хитов по версии iTunes',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              // Список чарта
              Column(
                children: charts.map((item) {
                  if (item.isSong) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: ChartItemTile(
                        item: item,
                        theme: theme,
                        isDark: isDark,
                      ),
                    );
                  } else {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: VideoAdCard(item: item, isDark: isDark),
                    );
                  }
                }).toList(),
              ),
            ],
          ),
        );
      },
      loading: () {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (error, _) {
        // При ошибке всё равно показываем fallback данные
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 48,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Загрузка fallback данных...',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColors.textName,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    ChartCategory category,
    bool isActive,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(chartCategoryProvider.notifier).state = category;
        ref.read(chartsProvider.notifier).setCategory(category);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: isActive
                ? Colors.black
                : (isDark ? Colors.white54 : Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceButton(
    WidgetRef ref,
    String label,
    ChartSource source,
    bool isActive,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(chartSourceProvider.notifier).state = source;
        ref.read(chartsProvider.notifier).setSource(source);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? AppColors.cardBackground : Colors.grey.shade300)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? (isDark
                      ? Colors.white24
                      : Colors.black.withValues(alpha: 0.24))
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isActive
                ? (isDark ? Colors.white : Colors.black87)
                : (isDark ? Colors.white38 : Colors.black38),
          ),
        ),
      ),
    );
  }
}
