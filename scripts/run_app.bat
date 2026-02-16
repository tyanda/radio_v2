@echo off
echo Запуск прокси-сервера на порту 5000...
start cmd /c "cd /d g:\radio_v2 && node server.js"

timeout /t 3 /nobreak >nul

echo Запуск Flutter-приложения...
flutter run -d chrome