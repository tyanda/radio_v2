#!/bin/bash

echo "Запуск прокси-сервера на порту 5000..."
cd "$(dirname "$0")"
node server.js &

# Ждем немного, чтобы сервер успел запуститься
sleep 3

echo "Запуск Flutter-приложения..."
flutter run -d chrome