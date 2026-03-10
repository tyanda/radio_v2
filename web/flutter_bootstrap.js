{{flutter_js}}
{{flutter_build_config}}

/**
 * Загрузчик Flutter Web для SakhaLive Radio.
 * Совместим с Flutter 3.22+ и обеспечивает удаление сплэш-экрана.
 */
_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const engine = await engineInitializer.initializeEngine();
    
    // Удаляем splash screen перед запуском приложения
    const splash = document.getElementById('splash');
    if (splash) {
      splash.style.opacity = '0';
      setTimeout(() => {
        splash.remove();
      }, 300);
    }
    
    await engine.runApp();
  }
});
