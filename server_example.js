// Пример серверного решения для обхода CORS
// server.js (Node.js с Express)

const express = require('express');
const cors = require('cors');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Разрешаем CORS для всех маршрутов
app.use(cors());

// Маршрут для получения данных с horo.mail.ru
app.get('/api/horo/:category/:sign', async (req, res) => {
  try {
    const { category, sign } = req.params;
    
    // Проверяем параметры для безопасности
    if (!['love', 'career', 'health'].includes(category) || 
        !['aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo', 'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'].includes(sign)) {
      return res.status(400).json({ error: 'Invalid category or sign' });
    }
    
    // Делаем запрос к внешнему API
    const response = await axios.get(`https://horo.mail.ru/ajax/get_current_info/?category=${category}&sign=${sign}`);
    
    // Возвращаем ответ клиенту
    res.json(response.data);
  } catch (error) {
    console.error('Error fetching horoscope:', error.message);
    res.status(500).json({ error: 'Failed to fetch horoscope data' });
  }
});

// Маршрут для других внешних API
app.get('/api/proxy', async (req, res) => {
  const { url } = req.query;
  
  if (!url) {
    return res.status(400).json({ error: 'URL parameter is required' });
  }
  
  try {
    // Проверяем, что URL принадлежит доверенному списку (для безопасности)
    const allowedDomains = ['horo.mail.ru', 'api.openweathermap.org', 'ysia.ru'];
    const parsedUrl = new URL(url);
    
    if (!allowedDomains.includes(parsedUrl.hostname)) {
      return res.status(403).json({ error: 'Domain not allowed' });
    }
    
    const response = await axios.get(url);
    res.json(response.data);
  } catch (error) {
    console.error('Error proxying request:', error.message);
    res.status(500).json({ error: 'Failed to proxy request' });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});