package com.nisan.period_tracker_app

import android.Manifest
import android.app.AlarmManager
import android.app.KeyguardManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {
    private var notificationResult: MethodChannel.Result? = null
    private var unlockResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val preferences = getSharedPreferences("luna_cycle_storage", MODE_PRIVATE)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "luna_cycle/storage"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "load" -> result.success(preferences.getString("state", null))
                "save" -> {
                    preferences.edit().putString("state", call.arguments as? String ?: "").apply()
                    result.success(null)
                }
                "clear" -> {
                    preferences.edit().remove("state").apply()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "luna_cycle/device"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "areNotificationsEnabled" -> result.success(areNotificationsEnabled())
                "requestNotifications" -> requestNotifications(result)
                "scheduleReminders" -> {
                    @Suppress("UNCHECKED_CAST")
                    result.success(scheduleReminders(call.arguments as? Map<String, Any?>))
                }
                "showTestNotification" -> {
                    @Suppress("UNCHECKED_CAST")
                    val args = call.arguments as? Map<String, Any?>
                    val shown = showNotification(
                        args?.get("title") as? String ?: "LunaCycle",
                        args?.get("message") as? String ?: "You have a LunaCycle reminder.",
                        args?.get("hideSensitive") as? Boolean ?: true
                    )
                    result.success(shown)
                }
                "unlock" -> unlockWithDeviceCredential(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun areNotificationsEnabled(): Boolean {
        val permissionGranted = Build.VERSION.SDK_INT < 33 ||
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
        if (!permissionGranted) return false
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return if (Build.VERSION.SDK_INT >= 24) {
            manager.areNotificationsEnabled()
        } else {
            true
        }
    }

    private fun requestNotifications(result: MethodChannel.Result) {
        val alreadyGranted = Build.VERSION.SDK_INT < 33 ||
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
        if (alreadyGranted) {
            result.success(areNotificationsEnabled())
            return
        }
        notificationResult?.success(false)
        notificationResult = result
        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 4100)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 4100) {
            val granted = grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            notificationResult?.success(granted && areNotificationsEnabled())
            notificationResult = null
        }
    }

    private fun unlockWithDeviceCredential(result: MethodChannel.Result) {
        val keyguard = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        if (!keyguard.isDeviceSecure) {
            result.success(false)
            return
        }
        val intent = keyguard.createConfirmDeviceCredentialIntent(
            "Unlock LunaCycle",
            "Use your phone lock to open your private cycle diary."
        )
        if (intent == null) {
            result.success(false)
            return
        }
        unlockResult?.success(false)
        unlockResult = result
        startActivityForResult(intent, 4101)
    }

    @Deprecated("Deprecated in Android API")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 4101) {
            unlockResult?.success(resultCode == RESULT_OK)
            unlockResult = null
        }
    }

    private fun scheduleReminders(arguments: Map<String, Any?>?): Boolean {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        cancelReminders(alarmManager)

        val enabled = arguments?.get("enabled") as? Boolean ?: true
        if (!enabled) return true
        if (!areNotificationsEnabled()) return false

        val hideSensitive = arguments?.get("hideSensitive") as? Boolean ?: true
        val reminders = arguments?.get("reminders") as? List<*> ?: emptyList<Any>()
        reminders.take(12).forEachIndexed { index, item ->
            val reminder = item as? Map<*, *> ?: return@forEachIndexed
            val hour = ((reminder["hour"] as? Number)?.toInt() ?: 8).coerceIn(0, 23)
            val minute = ((reminder["minute"] as? Number)?.toInt() ?: 0).coerceIn(0, 59)
            val title = reminder["title"] as? String ?: "LunaCycle"
            val rawMessage = reminder["message"] as? String ?: "You have a LunaCycle reminder."
            val message = if (hideSensitive) {
                "You have a LunaCycle reminder."
            } else {
                rawMessage
            }

            val intent = Intent(this, ReminderReceiver::class.java).apply {
                putExtra("title", title)
                putExtra("message", message)
                putExtra("hideSensitive", hideSensitive)
            }
            val pendingIntent = PendingIntent.getBroadcast(
                this,
                index,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val calendar = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, hour)
                set(Calendar.MINUTE, minute)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
                if (timeInMillis <= System.currentTimeMillis()) {
                    add(Calendar.DAY_OF_YEAR, 1)
                }
            }
            alarmManager.setInexactRepeating(
                AlarmManager.RTC_WAKEUP,
                calendar.timeInMillis,
                AlarmManager.INTERVAL_DAY,
                pendingIntent
            )
        }
        return true
    }

    private fun cancelReminders(alarmManager: AlarmManager) {
        for (id in 0 until 12) {
            val cancelIntent = PendingIntent.getBroadcast(
                this,
                id,
                Intent(this, ReminderReceiver::class.java),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(cancelIntent)
        }
    }

    private fun showNotification(title: String, message: String, hideSensitive: Boolean): Boolean {
        if (!areNotificationsEnabled()) return false

        val channelId = "luna_cycle_reminders"
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= 26) {
            manager.createNotificationChannel(
                NotificationChannel(
                    channelId,
                    "LunaCycle reminders",
                    NotificationManager.IMPORTANCE_DEFAULT
                )
            )
        }
        val openIntent = packageManager.getLaunchIntentForPackage(packageName)
            ?: Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            9300,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val builder = if (Build.VERSION.SDK_INT >= 26) {
            Notification.Builder(this, channelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        val notification = builder
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(message)
            .setStyle(Notification.BigTextStyle().bigText(message))
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setVisibility(
                if (hideSensitive) Notification.VISIBILITY_PRIVATE
                else Notification.VISIBILITY_PUBLIC
            )
            .build()
        manager.notify(9100, notification)
        return true
    }
}
