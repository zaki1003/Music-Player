package com.example.tp7



import android.app.Activity
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.logging.StreamHandler
import kotlin.math.pow

class MainActivity : FlutterActivity(),EventChannel.StreamHandler, SensorEventListener {
    private val METHODCHANNEL = "example_service"
    private val EVENTCHANNEL = "event_channel"


    private lateinit var sensorManager : SensorManager

    private var accelerometerSensor : Sensor? = null



    companion object {
        var songName : String = ""
      var path : String = ""
      var eventSink: EventChannel.EventSink? = null
    }
 @RequiresApi(Build.VERSION_CODES.Q)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)



        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHODCHANNEL).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->
            when (call.method) {
                "startExampleService" -> {
                    songName = call.argument<String>("name").toString()
                    path = call.argument<String>("uri").toString()
                    startService(Intent(this, ExampleService::class.java))
                    result.success("Started!")
                }
                "updateExampleService" -> {
                    songName = call.argument<String>("name").toString()
                    path = call.argument<String>("uri").toString()
                    ExampleService.Companion.updateNotification(songName, path)
                    result.success(songName)
                }
                "pauseMusic" -> {
                    if (ExampleService.player?.isPlaying == true) ExampleService.player?.pause() else ExampleService.player?.start()
                    result.success(songName)
                }
                "stopExampleService" -> {
                    stopService(Intent(this, ExampleService::class.java))
                    result.success("Stopped!")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
     sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager

     accelerometerSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

     val event = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENTCHANNEL)
        event.setStreamHandler(this)
    }


    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        //Do Nothing
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if(event!!.sensor.type == Sensor.TYPE_ACCELEROMETER){

            val value = Math.sqrt((event.values[0].pow(2)  + event.values[1].pow(2) + event.values[2].pow(2)).toDouble())

            if (value > 20)

                if (ExampleService.player?.isPlaying == true)
           {

                ExampleService.player?.pause()
                eventSink!!.success("Pause")} else

            {ExampleService.player?.start()
                eventSink!!.success("Play")

            }



        }

    }
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {

       eventSink = events
        registerSensor()
    }

    override fun onCancel(arguments: Any?) {
        unRegisterSensor()
        eventSink = null
    }

    //Register SensorManger
    private fun registerSensor() {
        if(eventSink == null) return
        accelerometerSensor = sensorManager!!.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

        sensorManager.registerListener(this, accelerometerSensor, SensorManager.SENSOR_DELAY_UI)


    }

    //UnregisterSensor

    private fun unRegisterSensor() {
        if(eventSink == null) return
        sensorManager.unregisterListener(this)
    }

}