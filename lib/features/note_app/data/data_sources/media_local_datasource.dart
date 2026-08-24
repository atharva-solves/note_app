import 'package:note_app/features/note_app/domain/enums/media_attachment_enums.dart';
import 'package:image_picker/image_picker.dart';

abstract class MediaLocalDatasource {
  Future<List<String>> pickMedia({
    required NoteMediaSource mediaSource,
    required NoteMediaType mediaType,
  });
}

class MediaLocalDatasourceImpl implements MediaLocalDatasource {
  final ImagePicker _imagePicker;

  MediaLocalDatasourceImpl({required ImagePicker imagePicker})
    : _imagePicker = imagePicker;

  @override
  Future<List<String>> pickMedia({
    required NoteMediaSource mediaSource,
    required NoteMediaType mediaType,
  }) async {
    List<String> rawPaths = [];
    if (mediaSource == NoteMediaSource.camera) {
      if (mediaType == NoteMediaType.image) {
        //native os limitation , only one photo capture
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
        );

        //since single(.add) nullable (user Discards process) Xfile
        //null check
        if (image != null) rawPaths.add(image.path);
      } else {
        //deafault remaining Vid
        final XFile? video = await _imagePicker.pickVideo(
          source: ImageSource.camera,
        );
        if (video != null) rawPaths.add(video.path);
      }
    } else if (mediaSource == NoteMediaSource.gallery) {
      //if user discards then insted of null, we're handed an Empty list
      //so Null check req
      //emp list is added to deafault empty list

      if (mediaType == NoteMediaType.image) {
        final List<XFile> images = await _imagePicker.pickMultiImage();
        rawPaths.addAll(images.map((file) => file.path));
      } else if (mediaType == NoteMediaType.video) {
        final List<XFile> videos = await _imagePicker.pickMultiVideo();
        rawPaths.addAll(videos.map((file) => file.path));
      } else if (mediaType == NoteMediaType.any) {
        final List<XFile> mixedMedia = await _imagePicker.pickMultipleMedia();
        rawPaths.addAll(mixedMedia.map((file) => file.path));
      }
    }

    return rawPaths;
  }
}
