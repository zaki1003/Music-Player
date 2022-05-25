package com.example.tp7


import android.app.*
import android.app.PendingIntent.FLAG_MUTABLE
import android.app.PendingIntent.FLAG_UPDATE_CURRENT
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.IBinder
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import java.security.AccessController.getContext

class ExampleService : Service() {


   companion object {
       var player: MediaPlayer? = null

       val notificationId = 1
       var serviceRunning = false


       lateinit var builder: NotificationCompat.Builder
       lateinit var channel: NotificationChannel
       lateinit var manager: NotificationManager

       fun stopSound() {
           if (player != null) {
               player!!.stop()
               player!!.release()
               player = null
           }
       }

       fun playContentUri(uri: Uri) {

           player = MediaPlayer().apply {
               setDataSource(app, uri)
           /*     setAudioAttributes(AudioAttributes.Builder()
                          .setUsage(AudioAttributes.USAGE_MEDIA)
                          .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                          .build()
                  )*/
               prepare()
               start()
           }
       }
       var app : Application = Application()
       fun updateNotification(text: String, path: String) {
           player!!.stop();
           playContentUri(Uri.parse(path));

           builder
                   .setContentText(text)
           manager.notify(notificationId, builder.build());
       }


   }


    override fun onCreate() {
        super.onCreate()

        app = application
        playContentUri( Uri.parse(MainActivity.path))
        startForeground()
        serviceRunning = true

    }


    override fun onDestroy() {
        super.onDestroy()
        serviceRunning = false
        stopSound()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun createNotificationChannel(channelId: String, channelName: String): String {
        channel = NotificationChannel(channelId,
                channelName, NotificationManager.IMPORTANCE_NONE)
        channel.lightColor = Color.BLUE
        channel.lockscreenVisibility = Notification.VISIBILITY_PRIVATE
        manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
        return channelId
    }

    private fun startForeground() {
        val channelId =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    createNotificationChannel("example_service", "Example Service")
                } else {
                    // If earlier version channel ID is not used
                    // https://developer.android.com/reference/android/support/v4/app/NotificationCompat.Builder.html#NotificationCompat.Builder(android.content.Context)
                    ""
                }

     val broadcastPauseIntent = Intent(application, MyReceiver::class.java).apply {
         setAction("Pause")
        }


        val broadCastPause: PendingIntent =
                PendingIntent.getBroadcast(application, 0, broadcastPauseIntent, 0)




        val broadcastNextIntent = Intent(application, MyReceiver::class.java).apply {

            setAction("Next")
        }

        val broadCastNext: PendingIntent =
                PendingIntent.getBroadcast(application, 0, broadcastNextIntent, 0)



        val broadcastBackIntent = Intent(application, MyReceiver::class.java).apply {
            putExtra("action_msg", "Back")
            setAction("Back")
  }


        val broadCastBack: PendingIntent =
                PendingIntent.getBroadcast(application, 0, broadcastBackIntent, 0)




        builder = NotificationCompat.Builder(this, channelId)
        builder
                .setOngoing(true)
                .setOnlyAlertOnce(true)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("Service Music")
                .setContentText(MainActivity.Companion.songName)
                .setCategory(Notification.CATEGORY_SERVICE)
                .addAction(R.drawable.btn, "Back", broadCastBack)
                .addAction(R.drawable.btn, "Pause/Play", broadCastPause)
                .addAction(R.drawable.btn, "Next", broadCastNext)





        startForeground(1, builder.build())
    }


    override fun onBind(intent: Intent): IBinder? {
        return null
    }
}

