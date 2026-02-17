// Прокси-сервер для horo.mail.ru
const express = require('express');
const axios = require('axios');

const app = express();
const PORT = 5000;

app.get('/proxy', async (req, res) => {
  const targetUrl = req.query.url;
  
  if (!targetUrl || !targetUrl.includes('horo.mail.ru')) {
    return res.status(400).json({ error: 'Invalid URL' });
  }

  try {
    const response = await axios.get(targetUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
      },
    });

    res.set('Content-Type', 'text/html; charset=utf-8');
    res.set('Access-Control-Allow-Origin', '*');
    res.send(response.data);
  } catch (error) {
    console.error('Proxy error:', error.message);
    res.status(500).json({ error: 'Proxy error', details: error.message });
  }
});

app.get('/api/status', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`Proxy server running on http://localhost:${PORT}`);
  console.log('Endpoints:');
  console.log('  GET /proxy?url=<horo.mail.ru URL>');
  console.log('  GET /api/status');
});
