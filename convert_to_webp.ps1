# Скрипт для конвертации изображений в WebP
# Требует установки cwebp: https://developers.google.com/speed/webp/download

param(
    [int]$quality = 85
)

$sourceDir = "assets\images"
$outputDir = "assets\images_webp"

# Создаём выходную директорию
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
    Write-Host "Создана директория: $outputDir"
}

# Находим cwebp
$cwebpPaths = @(
    "C:\Program Files\WebP\cwebp.exe",
    "C:\Program Files (x86)\WebP\cwebp.exe",
    ".\cwebp.exe",
    "cwebp.exe"
)

$cwebp = $null
foreach ($path in $cwebpPaths) {
    if (Test-Path $path) {
        $cwebp = $path
        break
    }
}

if (!$cwebp) {
    Write-Host "❌ cwebp не найден! Скачайте с: https://developers.google.com/speed/webp/download"
    Write-Host "Распакуйте в C:\Program Files\WebP\ или в корень проекта"
    exit 1
}

Write-Host "✅ cwebp найден: $cwebp"
Write-Host "📷 Конвертация изображений с качеством: $quality%"
Write-Host ""

$converted = 0
$totalSaved = 0

# Конвертируем JPG и JPEG файлы
Get-ChildItem -Path $sourceDir -Include *.jpg,*.jpeg,*.png -Recurse | ForEach-Object {
    $inputFile = $_.FullName
    $outputFile = Join-Path $outputDir ($_.BaseName + ".webp")
    
    Write-Host "🔄 Конвертация: $($_.Name) → $($_.BaseName).webp"
    
    # Конвертация
    $process = Start-Process -FilePath $cwebp -ArgumentList "-q $quality `"$inputFile`" -o `"$outputFile`"" -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -eq 0) {
        $originalSize = (Get-Item $inputFile).Length
        $compressedSize = (Get-Item $outputFile).Length
        $saved = $originalSize - $compressedSize
        $savedPercent = [math]::Round(($saved / $originalSize) * 100, 2)
        
        $converted++
        $totalSaved += $saved
        
        Write-Host "   ✅ Размер: $([math]::Round($originalSize/1KB, 2)) KB → $([math]::Round($compressedSize/1KB, 2)) KB (экономия: $savedPercent%)"
    } else {
        Write-Host "   ❌ Ошибка конвертации"
    }
}

Write-Host ""
Write-Host "════════════════════════════════════════════"
Write-Host "✅ Конвертация завершена!"
Write-Host "📊 Конвертировано файлов: $converted"
Write-Host "💾 Общая экономия: $([math]::Round($totalSaved/1KB, 2)) KB ($([math]::Round($totalSaved/1MB, 2)) MB)"
Write-Host "════════════════════════════════════════════"
Write-Host ""
Write-Host "📝 Следующие шаги:"
Write-Host "1. Обновите pubspec.yaml (используйте .webp файлы)"
Write-Host "2. Замените в коде .jpg на .webp"
Write-Host "3. Запустите: flutter build web --release"
