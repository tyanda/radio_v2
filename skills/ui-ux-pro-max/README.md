# UI/UX Pro Max для Flutter

> Адаптация [ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) для Flutter-разработки

## 📋 Обзор

**UI/UX Pro Max Skill** — это AI-навык для генерации профессиональных дизайн-систем. Мы адаптировали его для Flutter с использованием **shadcn_ui**.

## 🎨 Дизайн-токены

### Цветовая палитра (shadcn_ui)

```dart
// lib/core/design/design_tokens.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary (Brand)
  static const primary = Color(0xFF10B981);      // Emerald 500
  static const primaryDark = Color(0xFF059669);  // Emerald 600
  static const primaryLight = Color(0xFF34D399); // Emerald 400
  
  // Secondary
  static const secondary = Color(0xFF6366F1);    // Indigo 500
  static const secondaryDark = Color(0xFF4F46E5);// Indigo 600
  static const secondaryLight = Color(0xFF818CF8);// Indigo 400
  
  // Background
  static const background = Color(0xFFFFFFFF);
  static const backgroundDark = Color(0xFF0F172A); // Slate 900
  static const surface = Color(0xFFF8FAFC);        // Slate 50
  
  // Text
  static const textPrimary = Color(0xFF1E293B);    // Slate 800
  static const textSecondary = Color(0xFF64748B);  // Slate 500
  static const textLight = Color(0xFFFFFFFF);
  
  // Semantic
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
  
  // Borders
  static const border = Color(0xFFE2E8F0);
  static const borderDark = Color(0xFF475569);
}
```

### Типография

```dart
// lib/core/design/typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Шрифтовая пара: Inter (заголовки) + Inter (текст)
  // Альтернатива: Cormorant Garamond / Montserrat для элегантности
  
  static TextTheme get textTheme {
    return GoogleFonts.interTextTheme();
  }
  
  // Заголовки
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.semibold,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  static const h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // Текст
  static const bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 14,
    height: 1.5,
  );
  
  static const bodySmall = TextStyle(
    fontSize: 12,
    height: 1.4,
  );
  
  // Кнопки
  static const button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
}
```

### Эффекты (Shadows & Radius)

```dart
// lib/core/design/effects.dart
import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppEffects {
  // Тени (Soft UI Evolution)
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];
  
  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
  
  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
  
  // Скругления
  static const radiusSm = 4.0;
  static const radiusMd = 8.0;
  static const radiusLg = 12.0;
  static const radiusXl = 16.0;
  static const radiusFull = 9999.0;
  
  // Анимации
  static const durationFast = Duration(milliseconds: 150);
  static const durationNormal = Duration(milliseconds: 200);
  static const durationSlow = Duration(milliseconds: 300);
  
  static const curve = Curves.easeInOut;
}
```

### Отступы (Spacing)

```dart
// lib/core/design/spacing.dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}
```

## 🎯 UI Стили (67 стилей)

### Soft UI Evolution (для Radio App)

```dart
// lib/core/design/themes/soft_ui_theme.dart
import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../typography.dart';
import '../effects.dart';

class SoftUITheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Colors
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      
      // Typography
      textTheme: AppTypography.textTheme,
      
      // Card Theme
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppEffects.radiusLg),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppEffects.radiusMd),
          ),
          textStyle: AppTypography.button,
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppEffects.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppEffects.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppEffects.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.backgroundDark,
        error: AppColors.error,
      ),
      
      textTheme: AppTypography.textTheme.apply(bodyColor: AppColors.textLight),
      
      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppEffects.radiusLg),
          side: const BorderSide(color: AppColors.borderDark),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppEffects.radiusMd),
          ),
          textStyle: AppTypography.button,
        ),
      ),
    );
  }
}
```

## 📐 Паттерны лендингов (24 паттерна)

### Hero-Centric Pattern (для Radio App)

```dart
// lib/features/home/widgets/hero_section.dart
import 'package:flutter/material.dart';
import '../../../core/design/design_tokens.dart';
import '../../../core/design/spacing.dart';
import '../../../core/design/effects.dart';
import '../../../l10n/app_localizations.dart';

class HeroSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPlayPressed;
  
  const HeroSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPlayPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppEffects.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Заголовок
          Text(
            title,
            style: AppTypography.h1.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Подзаголовок
          Text(
            subtitle,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // CTA Кнопка
          ElevatedButton.icon(
            onPressed: onPlayPressed,
            icon: const Icon(Icons.play_arrow, size: 24),
            label: Text(l10n.playNow),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.lg,
              ),
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
```

## ✅ Pre-delivery Checklist для виджетов

```dart
// lib/core/design/checklist.dart

/// Pre-delivery Checklist для Flutter виджетов
/// 
/// Автоматическая валидация перед завершением задачи:
/// 
/// - [ ] Нет хардкод цветов (используй AppColors)
/// - [ ] Нет хардкод отступов (используй AppSpacing)
/// - [ ] Все кликабельные элементы имеют feedback (InkWell/onPressed)
/// - [ ] Hover states с плавными transitions (150-300ms)
/// - [ ] Focus states visible для keyboard navigation
/// - [ ] Responsive: 375px, 768px, 1024px, 1440px
/// - [ ] i18n: все строки через AppLocalizations
/// - [ ] Accessibility: семантические лейблы
/// - [ ] Dark mode совместимость
class DesignChecklist {
  // Этот класс используется как документация и напоминание
  // Реальная валидация происходит через flutter analyze и тесты
}
```

## 🎨 Поддерживаемые стили

### Для Radio App

| Стиль | Описание | Когда использовать |
|-------|----------|-------------------|
| **Soft UI Evolution** | Мягкие тени, плавные переходы | Основное приложение |
| **Minimalism** | Чистый, без лишнего | Настройки, профили |
| **Dark Mode** | Тёмная тема | Ночной режим |
| **Glassmorphism** | Эффект стекла | Модальные окна, оверлеи |

### Для будущих проектов

- **Neubrutalism** — Смелые границы, яркие цвета
- **Bento Grid** — Сеточная компоновка
- **Aurora UI** — Градиентные фоны
- **AI-Native UI** — Футуристичный дизайн

## 📦 Интеграция с shadcn_ui

```dart
// pubspec.yaml уже содержит:
dependencies:
  shadcn_ui: ^0.46.1

// lib/main.dart
import 'package:shadcn_ui/shadcn_ui.dart';
import 'core/design/themes/soft_ui_theme.dart';

void main() {
  runApp(
    ShadApp(
      title: 'Radio V4',
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadColorScheme.light(
          primary: AppColors.primary,
        ),
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadColorScheme.dark(
          primary: AppColors.primaryLight,
        ),
      ),
      home: const MyApp(),
    ),
  );
}
```

## 🔗 Ресурсы

- **Оригинал:** [ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)
- **shadcn_ui:** [pub.dev/packages/shadcn_ui](https://pub.dev/packages/shadcn_ui)
- **Google Fonts:** [pub.dev/packages/google_fonts](https://pub.dev/packages/google_fonts)
