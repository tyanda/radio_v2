#!/bin/bash
# scripts/pre-commit-check.sh
# Pre-commit проверка перед коммитом

set -e

echo "🚀 Pre-commit проверка..."
echo ""

# 1. Тесты
echo "🧪 Запуск тестов..."
flutter test || {
    echo "❌ Тесты не прошли"
    exit 1
}
echo "✅ Тесты пройдены"
echo ""

# 2. Анализ
echo "🔍 Статический анализ..."
flutter analyze || {
    echo "❌ Ошибки анализа"
    exit 1
}
echo "✅ Анализ пройден"
echo ""

# 3. Форматирование
echo "📝 Проверка форматирования..."
if dart format --set-exit-if-changed lib/ test/ > /dev/null 2>&1; then
    echo "✅ Код отформатирован"
else
    echo "❌ Код требует форматирования"
    echo "   Запустите: dart format lib/ test/"
    exit 1
fi
echo ""

# 4. Генерация
echo "⚙️  Генерация кода..."
flutter gen-l10n || {
    echo "❌ Ошибка генерации l10n"
    exit 1
}
echo "✅ Генерация пройдена"
echo ""

# 5. Проверка локализации
echo "🌍 Проверка локализации..."
if [ -f "scripts/check-l10n.sh" ]; then
    bash scripts/check-l10n.sh || {
        echo "❌ Локализация неполная"
        exit 1
    }
else
    echo "⚠️  Скрипт check-l10n.sh не найден, пропускаем"
fi
echo ""

echo "✅ Все проверки пройдены!"
echo ""
echo "Теперь можно сделать коммит:"
echo "  git add ."
echo "  git commit -m \"ваше сообщение\""
