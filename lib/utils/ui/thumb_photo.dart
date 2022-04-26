import 'package:image_picker/image_picker.dart';

class ThumbPhoto {
  String? uuid;
  XFile photo;
  bool isDummy;
  bool hasChanged;
  String state;

  ThumbPhoto({this.uuid, required XFile this.photo, required this.isDummy, required this.hasChanged, required this.state});
}