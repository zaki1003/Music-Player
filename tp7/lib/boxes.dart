import 'package:hive/hive.dart';

import 'package:tp7/models/audio_model.dart';

class Boxes {
  static Box<Audio> getAudios() => Hive.box<Audio>('FavoriteAudios');
}
