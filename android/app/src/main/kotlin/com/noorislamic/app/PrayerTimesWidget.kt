package com.noorislamic.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PrayerTimesWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.prayer_times_widget).apply {
                val prefs = HomeWidgetPlugin.getData(context)
                
                setTextViewText(R.id.widget_fajr, prefs?.getString("fajr", "---") ?: "---")
                setTextViewText(R.id.widget_dhuhr, prefs?.getString("dhuhr", "---") ?: "---")
                setTextViewText(R.id.widget_asr, prefs?.getString("asr", "---") ?: "---")
                setTextViewText(R.id.widget_maghrib, prefs?.getString("maghrib", "---") ?: "---")
                setTextViewText(R.id.widget_isha, prefs?.getString("isha", "---") ?: "---")
                
                val nextPrayer = prefs?.getString("next_prayer", "Fajr") ?: "Fajr"
                setTextViewText(R.id.widget_next_prayer, "Next: $nextPrayer")
            }
            
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
