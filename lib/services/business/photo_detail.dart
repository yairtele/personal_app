import 'package:image_picker/image_picker.dart';

class PhotoDetail {
  String uuid;
  XFile content;
  bool isDummy;
  String? state;
  bool hasChanged;

  PhotoDetail({
    required this.uuid,
    required this.content,
    required this.isDummy,
    required this.state,
    required this.hasChanged
  });

}