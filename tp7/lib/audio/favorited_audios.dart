import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tp7/models/audio_model.dart';

import '../boxes.dart';
import 'audio_screen.dart';

class FavoritedAudios extends StatefulWidget {
  GlobalKey<NavigatorState> navigatorKey;
  FavoritedAudios(this.navigatorKey);

  @override
  State<FavoritedAudios> createState() => _FavoritedAudiosState();
}

class _FavoritedAudiosState extends State<FavoritedAudios> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Mes favoris'),
          centerTitle: true,
        ),
        body: ValueListenableBuilder<Box<Audio>>(
          valueListenable: Boxes.getAudios().listenable(),
          builder: (context, box, _) {
            final audios = box.values.toList().cast<Audio>();

            return buildContent(audios);
          },
        ),

      );

  Widget buildContent(List<Audio> audios) {
    if (audios.isEmpty) {
      return Center(
        child: Text(
          'No Favorites Audios yet!',
          style: TextStyle(fontSize: 24),
        ),
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: audios.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => AudioScreen(
                                audios, index, widget.navigatorKey))),
                    child: Card(
                      child: ListTile(
                        leading: Container(
                          child: Image(
                            image: AssetImage("assets/images/music.png"),
                          ),
                        ),
                        title: Text(
                          audios[index].name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        // getting extension
                      ),
                    ));
              },
            ),
          ),
        ],
      );
    }
  }
}
