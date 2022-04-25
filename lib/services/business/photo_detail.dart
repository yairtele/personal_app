import 'package:image_picker/image_picker.dart';

class PhotoDetail {
  String uuid;
  XFile content;
  bool isDummy;

  PhotoDetail({
    required this.uuid,
    required this.content,
    required this.isDummy
  });

}