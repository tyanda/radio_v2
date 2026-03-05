#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# Скрипт деплоя Radio V4 на Firebase Hosting
# ═══════════════════════════════════════════════════════════════

set -e  # Остановить при ошибке

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║         🚀 Deploy Radio V4 to Firebase Hosting           ║"
echo "╚═══════════════════════════════════════════════════════════╝"

# Проверка Firebase CLI
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI не найден!"
    echo "📦 Установите: npm install -g firebase-tools"
    exit 1
fi

# Сборка веб-версии
echo ""
echo "🔨 Шаг 1/3: Сборка веб-версии..."
flutter build web --release

if [ $? -ne 0 ]; then
    echo "❌ Ошибка сборки!"
    exit 1
fi

echo "✅ Сборка завершена: build/web"

# Проверка авторизации
echo ""
echo "🔐 Шаг 2/3: Проверка авторизации..."
if ! firebase projects:list &> /dev/null; then
    echo "❌ Firebase не авторизован!"
    echo "👉 Выполните: firebase login"
    exit 1
fi

echo "✅ Firebase авторизован"

# Деплой
echo ""
echo "🌐 Шаг 3/3: Деплой на Firebase Hosting..."
firebase deploy --only hosting

if [ $? -ne 0 ]; then
    echo "❌ Ошибка деплоя!"
    exit 1
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                    ✅ Деплой успешен!                    ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Ваш сайт доступен:"
echo "   • https://sakhalive-ticker.web.app"
echo "   • https://sakhalive-ticker.firebaseapp.com"
echo ""
