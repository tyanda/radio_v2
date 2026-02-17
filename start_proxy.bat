@echo off
echo Запуск прокси-сервера для гороскопа...
cd /d "%~dp0server"
start "Horoscope Proxy" node server.js
timeout /t 2 /nobreak >nul
echo Прокси запущен на http://localhost:5000
echo.
echo Теперь запусти приложение:
echo   flutter run
echo.
pause
