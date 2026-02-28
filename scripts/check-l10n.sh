#!/bin/bash
# scripts/check-l10n.sh
# Проверка полноты локализации

set -e

echo "🔍 Проверка локализации..."

RU_FILE="lib/l10n/app_ru.arb"
EN_FILE="lib/l10n/app_en.arb"

if [ ! -f "$RU_FILE" ]; then
    echo "❌ Файл $RU_FILE не найден"
    exit 1
fi

if [ ! -f "$EN_FILE" ]; then
    echo "❌ Файл $EN_FILE не найден"
    exit 1
fi

# Извлечь ключи (исключая метаданные)
ru_keys=$(grep -o '"[^@][^"]*":' "$RU_FILE" | grep -v '^@@' | sort -u)
en_keys=$(grep -o '"[^@][^"]*":' "$EN_FILE" | grep -v '^@@' | sort -u)

# Найти отсутствующие ключи
missing_in_en=$(comm -23 <(echo "$ru_keys") <(echo "$en_keys"))
extra_in_en=$(comm -13 <(echo "$ru_keys") <(echo "$en_keys"))

error_found=0

if [ -n "$missing_in_en" ]; then
    echo "❌ Ключи отсутствуют в app_en.arb:"
    echo "$missing_in_en" | sed 's/^/  /'
    error_found=1
fi

if [ -n "$extra_in_en" ]; then
    echo "⚠️  Лишние ключи в app_en.arb:"
    echo "$extra_in_en" | sed 's/^/  /'
fi

if [ $error_found -eq 0 ]; then
    ru_count=$(echo "$ru_keys" | wc -l)
    echo "✅ Все $ru_count ключей локализованы"
    exit 0
else
    exit 1
fi
