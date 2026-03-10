# 📷 Конвертация изображений в WebP

## Способ 1: Автоматическая конвертация (рекомендуется)

### Шаг 1: Установите cwebp

Скачайте WebP utilities с официального сайта:
https://developers.google.com/speed/webp/download

**Для Windows:**
1. Скачайте `libwebp-*.zip` (последняя версия)
2. Распакуйте в `C:\Program Files\WebP\`
3. Добавьте в PATH или используйте полный путь

### Шаг 2: Запустите скрипт конвертации

```powershell
.\convert_to_webp.ps1 -quality 85
```

### Шаг 3: Проверьте результат

Скрипт создаст папку `assets/images_webp/` с конвертированными файлами.

---

## Способ 2: Ручная конвертация (онлайн)

Если не хотите устанавливать cwebp:

1. Откройте https://squoosh.app или https://cloudconvert.com/jpg-to-webp
2. Загрузите файлы из `assets/images/`
3. Скачайте WebP версии
4. Сохраните в `assets/images_webp/`

**Файлы для конвертации:**
- viktoria.jpg → viktoria.webp
- tetim.jpg → tetim.webp
- ir_radio.jpg → ir_radio.webp
- europa_plus.jpg → europa_plus.webp
- superdisco.jpg → superdisco.webp
- russkoe_radio.png → russkoe_radio.webp (опционально, PNG лучше оставить)
- radio_record_logo.png → radio_record_logo.webp (опционально)
- images.png → images.webp (опционально)
- record-russian-hits.png → record-russian-hits.webp (опционально)
- stv.jpeg → stv.webp

---

## Способ 3: Использовать оригинальные JPG (быстро, но меньше экономия)

Если нужна быстрая сборка без конвертации:

1. Измените `pubspec.yaml` обратно на `.jpg`
2. Измените файлы:
   - `lib/core/providers/radio_providers.dart`
   - `lib/features/radio/data/datasources/local_station_source.dart`

**Потеря экономии:** ~1-1.5 MB вместо ~2 MB

---

## Проверка после конвертации

```bash
# Проверка размеров
powershell -Command "Get-ChildItem assets/images_webp -Recurse -File | Measure-Object -Property Length -Sum | Select-Object @{Name='TotalMB';Expression={[math]::Round($_.Sum/1MB,2)}}"

# Сборка
flutter build web --release

# Тест
cd build/web
npx serve -l 8080
```

---

## Ожидаемая экономия

| Файл | Было (KB) | Стало (KB) | Экономия |
|------|-----------|------------|----------|
| superdisco.jpg | 444 | ~150 | 66% |
| stv.jpeg | 381 | ~130 | 66% |
| tetim.jpg | 280 | ~95 | 66% |
| viktoria.jpg | 260 | ~90 | 65% |
| **Всего** | **~1800** | **~600** | **67%** |

---

## Примечания

1. **Качество 85%** - оптимальный баланс между размером и качеством
2. **PNG файлы** - можно не конвертировать, если они с прозрачностью (логотипы)
3. **load.png, icon.png** - оставить PNG (используются в UI)

---

*Инструкция создана: 2026-03-09*
