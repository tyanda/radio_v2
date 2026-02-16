from PIL import Image, ImageDraw, ImageFont
import os

def create_superdisco_image():
    # Создаем изображение 400x400 с черным фоном
    img = Image.new('RGB', (400, 400), color='black')
    d = ImageDraw.Draw(img)
    
    # Рисуем цветные прямоугольники для создания диско-эффекта
    colors = ['red', 'blue', 'green', 'yellow', 'purple', 'orange']
    
    # Рисуем диагональные полосы
    for i in range(0, 400, 20):
        color = colors[i // 20 % len(colors)]
        d.rectangle([(i, 0), (i+20, 400)], fill=color)
    
    # Добавляем текст "СУПЕРДИСКОТЕКА 90-Х"
    try:
        # Используем стандартный шрифт
        fnt = ImageFont.load_default()
    except:
        fnt = None
    
    # Получаем размеры текста
    bbox = d.textbbox((0, 0), "СУПЕРДИСКОТЕКА\n90-Х", font=fnt)
    textwidth = bbox[2] - bbox[0]
    textheight = bbox[3] - bbox[1]
    
    # Позиционируем текст по центру
    x = (400 - textwidth) // 2
    y = (400 - textheight) // 2
    
    # Рисуем белый текст с черной обводкой для лучшей читаемости
    d.text((x, y), "СУПЕРДИСКОТЕКА\n90-Х", fill='white', font=fnt)
    
    # Сохраняем изображение
    img.save('assets/images/superdisco.jpg')
    print("Изображение 'superdisco.jpg' создано успешно!")

if __name__ == "__main__":
    # Создаем директорию, если она не существует
    os.makedirs('assets/images', exist_ok=True)
    create_superdisco_image()