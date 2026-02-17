// Cloudflare Worker для проксирования RSS
// Разместите этот код на https://workers.cloudflare.com/
// Бесплатный тариф: 100,000 запросов/день

// CORS Worker для RSS-ленты
// URL после деплоя: https://rss-proxy.<your-worker>.workers.dev/?url=<rss_url>

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  const url = new URL(request.url)
  const targetUrl = url.searchParams.get('url')
  
  // Проверяем наличие URL
  if (!targetUrl) {
    return new Response('Missing "url" parameter', { 
      status: 400,
      headers: { 'Content-Type': 'text/plain' }
    })
  }
  
  // Разрешаем только HTTPS URL
  if (!targetUrl.startsWith('https://')) {
    return new Response('Only HTTPS URLs are allowed', { 
      status: 403,
      headers: { 'Content-Type': 'text/plain' }
    })
  }
  
  try {
    // Делаем запрос к RSS-ленте
    const response = await fetch(targetUrl, {
      method: 'GET',
      headers: {
        'User-Agent': 'Mozilla/5.0 (compatible; SakhaRadio/1.0)',
        'Accept': 'application/rss+xml, application/xml, text/xml',
      },
    })
    
    // Получаем тело ответа
    const body = await response.text()
    
    // Возвращаем с CORS заголовками
    return new Response(body, {
      status: response.status,
      headers: {
        'Content-Type': 'application/rss+xml; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Cache-Control': 'public, max-age=300', // Кэшируем на 5 минут
      },
    })
  } catch (error) {
    return new Response(`Proxy error: ${error.message}`, { 
      status: 500,
      headers: { 
        'Content-Type': 'text/plain',
        'Access-Control-Allow-Origin': '*',
      }
    })
  }
}

// Обработка preflight запросов
addEventListener('fetch', event => {
  if (event.request.method === 'OPTIONS') {
    event.respondWith(handleOptionsRequest())
  }
})

function handleOptionsRequest() {
  return new Response(null, {
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Max-Age': '86400',
    },
  })
}
