// Прокси-сервер для обхода CORS в приложении radio_v2
// server.js (Node.js с Express)

const express = require('express');
const cors = require('cors');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Разрешаем CORS для всех маршрутов (в целях разработки)
app.use(cors({
  origin: '*' // В продакшене лучше указать конкретный домен
}));

// Парсим JSON-тела запросов
app.use(express.json());

// Маршрут для получения данных с horo.mail.ru
app.get('/api/horo/:category/:sign', async (req, res) => {
  try {
    const { category, sign } = req.params;

    // Проверяем параметры для безопасности
    const validCategories = ['love', 'career', 'health', 'today', 'tomorrow', 'week', 'month'];
    const validSigns = ['aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo', 'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'];
    
    if (!validCategories.includes(category) || !validSigns.includes(sign)) {
      return res.status(400).json({ error: 'Invalid category or sign' });
    }

    // Пробуем несколько разных URL для получения данных
    let response;
    const urls = [
      `https://horo.mail.ru/ajax/get_current_info/?category=${category}&sign=${sign}`,
      `https://horo.mail.ru/prediction/${sign}/${category}/`,
      `https://horo.mail.ru/prediction/${category}/${sign}/`
    ];

    let success = false;
    for (const url of urls) {
      try {
        response = await axios.get(url, {
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
            'Accept': 'application/json, text/html, */*',
            'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
            'Referer': 'https://horo.mail.ru/',
            'Origin': 'https://horo.mail.ru',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache'
          }
        });

        if (response.status === 200) {
          success = true;
          break;
        }
      } catch (err) {
        console.log(`Failed to fetch from ${url}: ${err.message}`);
        continue;
      }
    }

    if (!success) {
      return res.status(500).json({ error: 'Failed to fetch horoscope data from any source' });
    }

    // Возвращаем ответ клиенту
    if (response.headers['content-type'] && response.headers['content-type'].includes('application/json')) {
      res.json(response.data);
    } else {
      // Если возвращается HTML, оборачиваем в JSON
      res.json({ 
        html: response.data,
        category: category,
        sign: sign
      });
    }
  } catch (error) {
    console.error('Error fetching horoscope:', error.message);
    res.status(500).json({ error: 'Failed to fetch horoscope data' });
  }
});

// Маршрут для получения гороскопа по URL (альтернативный метод)
app.get('/api/horo-full/:sign/:period', async (req, res) => {
  try {
    const { sign, period } = req.params;

    // Проверяем параметры для безопасности
    const validSigns = ['aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo', 'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'];
    const validPeriods = ['today', 'tomorrow', 'week', 'month'];
    
    if (!validSigns.includes(sign) || !validPeriods.includes(period)) {
      return res.status(400).json({ error: 'Invalid sign or period' });
    }

    // Делаем запрос к внешнему API
    const response = await axios.get(`https://horo.mail.ru/prediction/${sign}/${period}/`, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        'Referer': 'https://horo.mail.ru/',
        'Origin': 'https://horo.mail.ru',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache'
      },
      timeout: 10000 // Таймаут 10 секунд
    });

    if (response.status === 200) {
      // Возвращаем HTML-контент для дальнейшей обработки на клиенте
      res.set('Content-Type', 'text/html; charset=utf-8');
      res.send(response.data);
    } else {
      res.status(response.status).json({ error: 'Failed to fetch horoscope page' });
    }
  } catch (error) {
    console.error('Error fetching horoscope page:', error.message);
    // Попробуем получить данные другим способом
    try {
      // Альтернативный URL-адрес
      const altResponse = await axios.get(`https://horo.mail.ru/forecast/${sign}/${period}/`, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
          'Referer': 'https://horo.mail.ru/',
          'Origin': 'https://horo.mail.ru',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache'
        },
        timeout: 10000
      });

      if (altResponse.status === 200) {
        res.set('Content-Type', 'text/html; charset=utf-8');
        res.send(altResponse.data);
      } else {
        res.status(altResponse.status).json({ error: 'Failed to fetch horoscope page' });
      }
    } catch (altError) {
      console.error('Alternative URL also failed:', altError.message);
      res.status(500).json({ error: 'Failed to fetch horoscope page from any source' });
    }
  }
});

// Универсальный прокси-маршрут для безопасных доменов
app.get('/api/proxy', async (req, res) => {
  const { url } = req.query;

  if (!url) {
    return res.status(400).json({ error: 'URL parameter is required' });
  }

  try {
    // Проверяем, что URL принадлежит доверенному списку (для безопасности)
    const allowedDomains = [
      'horo.mail.ru', 
      'api.openweathermap.org', 
      'ysia.ru',
      'api.telegram.org', // Добавим Telegram API если используется
      'theastrologypotion.com', // Астрологический API
      'api.nasa.gov', // Для астрономических данных
      'api.abalin.net' // Для ежедневных гороскопов
    ];
    
    let parsedUrl;
    try {
      parsedUrl = new URL(url);
    } catch (urlError) {
      return res.status(400).json({ error: 'Invalid URL format' });
    }

    if (!allowedDomains.includes(parsedUrl.hostname)) {
      return res.status(403).json({ error: 'Domain not allowed' });
    }

    const response = await axios.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7'
      }
    });
    
    res.json(response.data);
  } catch (error) {
    console.error('Error proxying request:', error.message);
    res.status(500).json({ error: 'Failed to proxy request' });
  }
});

// Специальный маршрут для альтернативного источника гороскопа
app.get('/api/horoscope/:sign', async (req, res) => {
  try {
    const { sign } = req.params;

    // Проверяем параметры для безопасности
    const validSigns = ['aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo', 'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'];
    
    if (!validSigns.includes(sign)) {
      return res.status(400).json({ error: 'Invalid sign' });
    }

    // Попробуем получить данные из альтернативного источника
    // Используем API abalin.net как резервный вариант
    try {
      const response = await axios.get(`https://api.abalin.net/byday?sign=${sign}&day=today`, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
          'Accept': 'application/json, text/plain, */*',
          'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
          'Referer': 'https://api.abalin.net/',
          'Origin': 'https://api.abalin.net'
        }
      });

      if (response.status === 200 && response.data?.data?.[0]) {
        // Преобразуем ответ к стандартному формату
        const horoscopeData = {
          sign: sign,
          date: new Date().toISOString().split('T')[0],
          horoscope: response.data.data[0].horoscope,
          mood: response.data.data[0].mood,
          color: response.data.data[0].color,
          lucky_number: response.data.data[0].lucky_number,
          lucky_time: response.data.data[0].lucky_time
        };
        
        res.json(horoscopeData);
        return;
      }
    } catch (apiError) {
      console.log('Primary alternative API failed:', apiError.message);
    }

    // Если первый альтернативный API не сработал, пробуем другой
    try {
      // Пробуем получить данные из другого источника
      // Используем универсальный прокси для безопасного получения данных
      const proxyResponse = await axios.get(`https://theastrologypotion.com/daily-horoscope/${sign}-daily-horoscope.php`, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
          'Referer': 'https://theastrologypotion.com/',
          'Origin': 'https://theastrologypotion.com'
        }
      });

      if (proxyResponse.status === 200) {
        // Возвращаем HTML-контент для дальнейшей обработки на клиенте
        res.json({
          sign: sign,
          date: new Date().toISOString().split('T')[0],
          html: proxyResponse.data,
          source: 'theastrologypotion.com'
        });
        return;
      }
    } catch (secondaryApiError) {
      console.log('Secondary alternative API failed:', secondaryApiError.message);
    }

    // Если все альтернативные источники не сработали, возвращаем ошибку
    res.status(500).json({ error: 'Failed to fetch horoscope data from any alternative source' });
  } catch (error) {
    console.error('Error fetching horoscope from alternative sources:', error.message);
    res.status(500).json({ error: 'Failed to fetch horoscope data' });
  }
});

// POST маршрут для универсального прокси (если нужно отправлять данные)
app.post('/api/proxy', express.json(), async (req, res) => {
  const { url, body, headers } = req.body;

  if (!url) {
    return res.status(400).json({ error: 'URL parameter is required' });
  }

  try {
    // Проверяем, что URL принадлежит доверенному списку (для безопасности)
    const allowedDomains = [
      'horo.mail.ru', 
      'api.openweathermap.org', 
      'ysia.ru',
      'api.telegram.org'
    ];
    
    let parsedUrl;
    try {
      parsedUrl = new URL(url);
    } catch (urlError) {
      return res.status(400).json({ error: 'Invalid URL format' });
    }

    if (!allowedDomains.includes(parsedUrl.hostname)) {
      return res.status(403).json({ error: 'Domain not allowed' });
    }

    const response = await axios({
      method: 'POST',
      url: url,
      data: body || {},
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
        ...(headers || {})
      }
    });
    
    res.json(response.data);
  } catch (error) {
    console.error('Error proxying POST request:', error.message);
    res.status(500).json({ error: 'Failed to proxy POST request' });
  }
});

// Маршрут для проверки состояния сервера
app.get('/api/status', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Обработка 404 для несуществующих маршрутов
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Глобальный обработчик ошибок
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Proxy server available at http://localhost:${PORT}`);
  console.log('Available routes:');
  console.log('  GET  /api/horo/:category/:sign - Get horoscope data');
  console.log('  GET  /api/horo-full/:sign/:period - Get full horoscope page');
  console.log('  GET  /api/proxy?url=<url> - Universal proxy for allowed domains');
  console.log('  POST /api/proxy - POST proxy for allowed domains');
  console.log('  GET  /api/status - Check server status');
});

module.exports = app;