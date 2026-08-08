import 'package:note_app/features/note_app/domain/enums/media_attachment_enums.dart';

abstract class MediaAttachementRepository {
  Future<List<String>> pickMedia({
    required NoteMediaSource source,
    required NoteMediaType type,
  });

  Future<String> uploadMedia({
    required String mediaLocalPath,
    required String userAuthId,
  });

  Future<List<String>> uploadMultipleMedia({
    required List<String> mediaLocalPaths,
    required String userAuthId,
  });
}
