import 'package:note_app/features/note_app/domain/enums/media_attachment_enums.dart';

class MediaAttachmentNestedEntity {
  final NoteMediaType mediaType;
  final String mediaLink;
  MediaAttachmentNestedEntity({
    required this.mediaType,
    required this.mediaLink,
  });
}
