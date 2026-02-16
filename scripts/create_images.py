import os
from PIL import Image, ImageDraw, ImageFont
import sys

def create_placeholder_image(filename, text, size=(200, 200)):
    """Создает простое изображение-заглушку с текстом"""
    img = Image.new('RGB', size, color='darkblue')
    d = ImageDraw.Draw(img)
    
    # Попробуем использовать стандартный шрифт
    try:
        # Для разных операционных систем пути к шрифтам могут отличаться
        if sys.platform.startswith('win'):
            font = ImageFont.truetype("arial.ttf", 40)
        elif sys.platform.startswith('darwin'):  # macOS
            font = ImageFont.truetype("Arial.ttf", 40)
        else:  # Linux и другие
            font = ImageFont.load_default()
    except:
        font = ImageFont.load_default()
    
    # Рассчитываем позицию текста по центру
    bbox = d.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    position = ((size[0] - text_width) / 2, (size[1] - text_height) / 2)
    
    d.text(position, text, fill='white', font=font)
    img.save(filename)

# Создаем папку, если она не существует
os.makedirs('assets/images', exist_ok=True)

# Создаем изображения для радиостанций
stations = [
    ('assets/images/viktoria.jpg', 'Виктория'),
    ('assets/images/tetim.jpg', 'Тэтим'),
    ('assets/images/ir_radio.jpg', 'IR Radio'),
    ('assets/images/europa_plus.jpg', 'Европа Плюс')
]

for filepath, station_name in stations:
    create_placeholder_image(filepath, station_name)
    print(f'Создано изображение: {filepath}')