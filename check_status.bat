@echo off
echo Проверка состояния сервисов...

echo.
echo Проверка прокси-сервера на порту 5000...
curl -s -o nul -w "%%{http_code}" http://localhost:5000/api/status
if %errorlevel% equ 0 (
    echo Прокси-сервер запущен
) else (
    echo Прокси-сервер НЕ отвечает
)

echo.
echo Для проверки Flutter-приложения введите URL вручную
echo или используйте команду: flutter run -d chrome
echo Приложение будет запущено на случайном доступном порту.

echo.
pause