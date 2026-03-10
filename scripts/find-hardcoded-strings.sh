#!/bin/bash
# scripts/find-hardcoded-strings.sh
# Поиск хардкод строк в коде

echo "🔍 Поиск хардкод строк в виджетах Text..."
echo ""

# Поиск строк в Text()
found=$(grep -rn "Text(['\"].*['\"])") \
    lib/ \
    --include="*.dart" \
    --exclude-dir=l10n \
    2>/dev/null | \
    grep -v "AppLocalizations" | \
    grep -v "l10n" | \
    grep -v "key:" | \
    grep -v "semanticsLabel" | \
    grep -v "Icon" | \
    grep -v "//" || true

if [ -z "$found" ]; then
    echo "✅ Хардкод строки не найдены"
    exit 0
else
    echo "❌ Найдены потенциальные хардкод строки:"
    echo ""
    echo "$found"
    echo ""
    echo "Совет: Вынесите эти строки в lib/l10n/app_ru.arb"
    exit 1
fi
