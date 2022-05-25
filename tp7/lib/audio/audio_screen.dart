import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tp7/audio/favorited_audios.dart';
import 'package:tp7/main.dart';
import 'dart:async';
import '../models/audio_model.dart';
import '../boxes.dart';

class AudioScreen extends StatefulWidget {
  List<Audio> audios;
  int index;
  GlobalKey<NavigatorState> navigatorKey;
  AudioScreen(this.audios, this.index, this.navigatorKey);
  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  // code 2 services

  static const platform = const MethodChannel('example_service');
  String _serverState = 'Did not make the call yet';

  Future<void> _startService(String songName, String uri) async {
    try {
      final result = await platform
          .invokeMethod('startExampleService', {"name": songName, "uri": uri});
      setState(() {
        _serverState = result;
      });
    } on PlatformException catch (e) {
      print("Failed to invoke method: '${e.message}'.");
    }
  }

  Future<void> _updateService(String songName, String uri) async {
    try {
      final result = await platform
          .invokeMethod('updateExampleService', {"name": songName, "uri": uri});
      setState(() {
        _serverState = result;
      });
    } on PlatformException catch (e) {
      print("Failed to invoke method: '${e.message}'.");
    }
  }

  Future<void> _updateSong(String songName, String uri) async {
    try {
      _stopService();
      _startService(songName, uri);
    } on PlatformException catch (e) {
      print("Failed to invoke method: '${e.message}'.");
    }
  }

  Future<void> _pauseMusic() async {
    try {
      final result = await platform.invokeMethod('pauseMusic');
      setState(() {
        _serverState = result;
      });
    } on PlatformException catch (e) {
      print("Failed to invoke method: '${e.message}'.");
    }
  }

  Future<void> _stopService() async {
    try {
      final result = await platform.invokeMethod('stopExampleService');
      setState(() {
        _serverState = result;
      });
    } on PlatformException catch (e) {
      print("Failed to invoke method: '${e.message}'.");
    }
  }

  void _moveNext() {
    setState(() {
      if ((i + 1) < widget.audios.length) {
        i = i + 1;
        //  _updateService(widget.audios[i].name,widget.audios[widget.index].name);
        _updateSong(widget.audios[i].name, widget.audios[i].path);

        isPlaying = true;
        action = "";
      }
    });
  }

  void _moveBack() {
    setState(() {
      if ((i - 1) >= 0) {
        i = i - 1;
        //  _updateService(widget.audios[i].name,widget.audios[i].name);
        _updateSong(widget.audios[i].name, widget.audios[i].path);

        isPlaying = true;
        action = "";
      }
    });
  }

  List<double> _userAccelerometerValues;

  bool isPlaying = true;

  final _streamSubscriptionEvent = <StreamSubscription<dynamic>>[];

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptionEvent) {
      subscription.cancel();
    }
    _stopService();
  }

  int i = 0;
  double x = 0;
  double y = 0;
  double z = 0;
  String action = "";
  Widget audioWidget;
  @override
  void initState() {
    // TODO: implement initState

    i = widget.index;

    _startService(
        widget.audios[widget.index].name, widget.audios[widget.index].path);

    _streamSubscriptionEvent
        .add(EventChannel('event_channel').receiveBroadcastStream().listen(
      (data) {
        setState(() {
          action = data;
        });
      },
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (action == "Next") _moveNext();
    if (action == "Back") _moveBack();
    if (action == "Pause")
      setState(() {
        isPlaying = false;
        action = "";
      });
    if (action == "Play")
      setState(() {
        isPlaying = true;
        action = "";
      });
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text("Music Player"),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text("Mes Musiques"),
                  value: 1,
                ),
                PopupMenuItem(
                  child: Text("Mes Favoris"),
                  value: 2,
                ),
              ],
              onSelected: (int menu) {
                if (menu == 1) {
                  widget.navigatorKey.currentState.pushReplacement(
                      MaterialPageRoute(builder: (context) => MyApp()));
                }
                if (menu == 2) {
                  widget.navigatorKey.currentState.pushReplacement(
                      MaterialPageRoute(
                          builder: (context) =>
                              FavoritedAudios(widget.navigatorKey)));
                }
              },
            )
          ],
        ),
        body: ValueListenableBuilder<Box<Audio>>(
            valueListenable: Boxes.getAudios().listenable(),
            builder: (context, box, _) {
              final favoritedAudios = box.values.toList().cast<Audio>();
              List<String> FavouritedAudiospath = [];
              for (var f in favoritedAudios) {
                FavouritedAudiospath.add(f.path);
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      height: 100,
                      width: 100,
                      child: Image(
                        image: AssetImage("assets/images/music.png"),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => _moveBack(),
                        child: Container(
                            height: 50,
                            width: 50,
                            child: Image(
                              image: AssetImage("assets/images/previous.png"),
                            )),
                      ),
                      GestureDetector(
                        onTap: () {
                          _pauseMusic();
                          setState(() {
                            isPlaying = !isPlaying;
                          });
                        },
                        child: Center(
                          child: Container(
                            height: 60,
                            width: 60,
                            child: !isPlaying
                                ? Icon(
                                    Icons.play_arrow,
                                    size: 80.0,
                                    color: Colors.black,
                                  )
                                : Icon(
                                    Icons.pause,
                                    size: 80.0,
                                    color: Colors.black,
                                  ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _moveNext(),
                        child: Container(
                            height: 50,
                            width: 50,
                            child: Image(
                              image: AssetImage("assets/images/next.png"),
                            )),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FavouritedAudiospath.contains(widget.audios[i].path)
                          ? IconButton(
                              onPressed: () => deleteAudio(widget.audios[i]),
                              icon: Icon(
                                Icons.star,
                                size: 60,
                                color: Colors.yellow,
                              ),
                            )
                          : IconButton(
                              onPressed: () => addAudio(widget.audios[i]),
                              icon: Icon(
                                Icons.star_border,
                                size: 60,
                                color: Colors.yellow,
                              ),
                            ),
                      Column(
                        children: [
                          SizedBox(
                            height: 16,
                          ),
                          FittedBox(
                            child: Text(
                              widget.audios[i].name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              );
            }));
  }

  Future addAudio(Audio audio) async {
    final box = Boxes.getAudios();
    box.add(audio);

    //box.put('mykey', Audio);

    // final mybox = Boxes.getAudios();
    // final myAudio = mybox.get('key');
    // mybox.values;
    // mybox.keys;
  }

  void deleteAudio(Audio audio) {
    // final box = Boxes.getAudios();
    // box.delete(Audio.key);

    audio.delete();
    //setState(() => Audios.remove(Audio));
  }

  void deleteAllAudios() {
    final box = Boxes.getAudios();

    box.clear();

    //setState(() => Audios.remove(Audio));
  }
}
