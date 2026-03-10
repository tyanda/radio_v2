#!/bin/bash
# Скрипт для исправления проблемы с ld.lld в snap-версии Flutter
# Запускать с sudo: sudo bash fix_linux_build.sh

set -e

echo "=== Исправление проблемы с ld.lld для Flutter Linux ==="

# Находим директорию snap Flutter
SNAP_DIR=$(readlink -f /snap/flutter/current)
LLVM_DIR="$SNAP_DIR/usr/lib/llvm-10/bin"

echo "Flutter snap директория: $SNAP_DIR"
echo "LLVM директория: $LLVM_DIR"

# Проверяем наличие системного ld.lld
if [ ! -f /usr/bin/ld.lld ]; then
    echo "❌ Системный ld.lld не найден!"
    echo "Установите его: sudo apt-get install -y lld"
    exit 1
fi

echo "✓ Системный ld.lld найден: /usr/bin/ld.lld"

# Монтируем snap директорию с правами на запись
echo "📝 Монтирование snap директории с правами на запись..."
mount -o remount,rw "$SNAP_DIR"

# Копируем ld.lld
echo "📋 Копирование ld.lld в директорию Flutter..."
cp /usr/bin/ld.lld "$LLVM_DIR/ld.lld"

# Проверяем результат
if [ -f "$LLVM_DIR/ld.lld" ]; then
    echo "✓ ld.lld успешно скопирован"
    ls -la "$LLVM_DIR/ld.lld"
else
    echo "❌ Не удалось скопировать ld.lld"
    exit 1
fi

# Возвращаем snap директорию в режим только для чтения
echo "🔒 Возвращение snap директории в режим только для чтения..."
mount -o remount,ro "$SNAP_DIR"

echo ""
echo "=== Готово! ==="
echo "Теперь можно запустить приложение:"
echo "  flutter run -d linux"
echo ""
