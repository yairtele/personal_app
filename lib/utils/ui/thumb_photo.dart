import 'package:image_picker/image_picker.dart';

class ThumbPhoto {
  String? uuid;
  XFile photo;
  bool isDummy;
  bool hasChanged;

  ThumbPhoto({this.uuid, required XFile this.photo, required this.isDummy, required this.hasChanged});
}