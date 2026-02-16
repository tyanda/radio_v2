from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from parser import getHoro
from typing import Dict

app = FastAPI(
    title="SakhaLive Horoscope API",
    description="API для получения гороскопов с horo.mail.ru",
    version="1.0.0"
)

# Настройка CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "SakhaLive Horoscope API"}

@app.get("/horo/{sign}")
async def get_horoscope(sign: str) -> Dict[str, str]:
    """
    Получает гороскоп для указанного знака зодиака
    sign: знак зодиака (aries, taurus и т.д.)
    """
    # Проверка валидности знака зодиака
    valid_signs = [
        "aries", "taurus", "gemini", "cancer", "leo", "virgo",
        "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces"
    ]
    
    if sign not in valid_signs:
        raise HTTPException(status_code=400, detail="Неверный знак зодиака")
    
    # Получаем гороскоп через парсер
    result = getHoro(sign)
    
    if not result or result.get("text") == "Не удалось получить прогноз":
        raise HTTPException(status_code=500, detail="Не удалось получить гороскоп")
    
    return result

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)