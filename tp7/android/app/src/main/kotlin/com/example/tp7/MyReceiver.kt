package com.example.tp7

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.widget.Toast

class MyReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {

        if (intent?.getAction().equals("Pause"))
            if (ExampleService.player?.isPlaying == true){ ExampleService.player?.pause()
                MainActivity.eventSink?.success("Pause")
            } else {ExampleService.player?.start()
                MainActivity.eventSink?.success("Play")
            }
             else
           if (intent?.getAction().equals("Next"))
           { MainActivity.eventSink?.success("Next")

        }
           else  if (intent?.getAction().equals("Back"))
           {   MainActivity.eventSink?.success("Back")

           }
    }
    //      Toast.makeText(context, intent?.getStringExtra("action_msg"), Toast.LENGTH_SHORT).show()
}