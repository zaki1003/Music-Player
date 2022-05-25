import 'package:hive/hive.dart';

part 'audio_model.g.dart';

@HiveType(typeId: 0)
class Audio extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String path;
  @HiveField(2)
  String size;

  Audio(this.name, this.path, this.size);
}
