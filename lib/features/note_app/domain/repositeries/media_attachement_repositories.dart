import 'package:note_app/features/note_app/domain/enums/media_enums.dart';

abstract class MediaAttachementRepositories {
  Future<String?> pickMedia({
    required NoteMediaSource source,
    required NoteMediaType type,
  });

  Future<String> uploadMedia({
    required String mediaLocalPath,
    required String userAuthId,
  });
}
