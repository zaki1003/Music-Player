// framework
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// packages
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:tp7/audio/audio_screen.dart';

import 'package:tp7/models/audio_model.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(AudioAdapter());
  await Hive.openBox<Audio>('FavoriteAudios');
  final status = await Permission.mediaLibrary.request();
  if (status == PermissionStatus.granted) {
    print('Permission granted');
  } else if (status == PermissionStatus.denied) {
    print(
        'Denied. Show a dialog with a reason and again ask for the permission.');
  } else if (status == PermissionStatus.permanentlyDenied) {
    print('Take the user to the settings page.');
  }

  runApp(MyApp());
}

@immutable
class MyApp extends StatelessWidget {
  final navigatorKey = GlobalKey<NavigatorState>();
  List<Audio> audios = [];



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: Scaffold(
          appBar: AppBar(
            title: const Text("Mes Musiques"),
          ),
          body: FutureBuilder(
            future: _files(), // a previously-obtained Future<String> or null
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('Press button to start.');
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Text('Awaiting result...');
                case ConnectionState.done:
                  if (snapshot.hasError)
                    return Text('Error: ${snapshot.error}');
                  return snapshot.data != null
                      ? ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) => Card(
                                  child: GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            AudioScreen(
                                                audios, index, navigatorKey))),
                                child: ListTile(
                                  leading: Container(
                                    child: Image(
                                      image:
                                          AssetImage("assets/images/music.png"),
                                    ),
                                  ),
                                  title: Text(
                                    audios[index].name,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),

                                  // getting extension
                                ),
                              )))
                      : const Center(
                          child: Text("Nothing!"),
                        );
              }
              return null; // unreachable
            },
          )),
    );
  }

  _files() async {
    var root = await getExternalStorageDirectory();
    //  var fm = FileManager(root: Directory("/storage/emulated/0"));
    var fm = FileManager(
        root: Directory(
            root.path.replaceAll("Android/data/com.example.tp7/files", "")));
    var files = await fm.filesTree(
        //set fm.dirsTree() for directory/folder tree list
        excludedPaths: ["/storage/emulated/0/Android"], extensions: ["mp3"]);

    for (var i = 0; i < files.length; i++) {
      print("${files[i].path} ");
      audios.add(Audio(files[i].path.split("/").last, files[i].path,
          files[i].statSync().size.toString()));
    }

    return files;
  }
}
