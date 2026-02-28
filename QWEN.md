## Qwen Added Memories
- Пользователь работает над Flutter проектом Radio V4 (SakhaLive) - приложение радио с погодой и гороскопами
- Проект Radio V4 использует: Flutter 3.x, Dart 3.10+, Riverpod для состояния, Firebase (Realtime Database), shadcn_ui для UI, локализацию RU/EN
- Архитектура Radio V4: lib/core (утилиты, providers, theme), lib/features (home, radio, weather, horoscope, player, settings), lib/widgets, lib/services, lib/l10n
- В проекте Radio V4 используются навыки Superpowers: TDD (сначала тесты), systematic-debugging (4-фазный поиск багов), verification-before-completion (проверка перед коммитом)
- Правила разработки Radio V4: 1) TDD - сначала тесты по-русски, 2) Feature-first структура, 3) Riverpod для состояния, 4) i18n - все строки в ARB файлах, 5) Firebase через Repository
- Дизайн система Radio V4: фон #0D0D0D, карточки #1A1A1A, акцент #F2C94C (жёлтый), бренд #C9A53A (золотой), шрифты Inter и Poppins, закругления 20-24px
