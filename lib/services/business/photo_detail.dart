import 'package:image_picker/image_picker.dart';

class PhotoDetail {
  String? uuid;
  XFile? content;

  PhotoDetail({
    this.uuid,
    required this.content
  });

}