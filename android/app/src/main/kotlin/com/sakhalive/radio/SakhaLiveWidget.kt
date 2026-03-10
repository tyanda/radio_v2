package com.sakhalive.radio

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Виджет для главного экрана Android
 */
class SakhaLiveWidget : AppWidgetProvider() {

    companion object {
        const val ACTION_PLAY_PAUSE = "com.sakhalive.PLAY_PAUSE"
        const val ACTION_OPEN_APP = "com.sakhalive.OPEN_APP"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        
        val views = RemoteViews(context.packageName, R.layout.sakha_live_widget)
        
        // Получаем данные из SharedPreferences
        val stationName = prefs.getString("stationName", "SakhaLive") ?: "SakhaLive"
        val currentTrack = prefs.getString("currentTrack", "") ?: ""
        val isPlaying = prefs.getString("isPlaying", "0") == "1"

        // Устанавливаем данные
        views.setTextViewText(R.id.widget_station_name, stationName)
        views.setTextViewText(R.id.widget_current_track, currentTrack.ifEmpty { "Нажмите для запуска" })
        
        // Иконка play/pause
        views.setImageViewResource(
            R.id.widget_play_icon,
            if (isPlaying) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play
        )
        views.setImageViewResource(
            R.id.widget_play_pause_button,
            if (isPlaying) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play
        )

        // Кнопка Play/Pause
        val playPauseIntent = Intent(context, SakhaLiveWidget::class.java).apply {
            action = ACTION_PLAY_PAUSE
        }
        val playPausePendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            playPauseIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_play_pause_button, playPausePendingIntent)

        // Кнопка открытия приложения
        val openAppIntent = Intent(context, MainActivity::class.java).apply {
            action = ACTION_OPEN_APP
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val openAppPendingIntent = PendingIntent.getActivity(
            context,
            0,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_open_app_button, openAppPendingIntent)
        
        // Клик по всему виджету тоже открывает приложение
        val widgetPendingIntent = PendingIntent.getActivity(
            context,
            0,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_root, widgetPendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        when (intent.action) {
            ACTION_PLAY_PAUSE -> {
                // Открываем приложение для управления воспроизведением
                val openAppIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("action", "play_pause")
                }
                context.startActivity(openAppIntent)
            }
            ACTION_OPEN_APP -> {
                val openAppIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                context.startActivity(openAppIntent)
            }
        }
    }
}
