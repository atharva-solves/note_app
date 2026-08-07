import 'package:note_app/features/note_app/domain/enums/media_enums.dart';
import 'package:note_app/features/note_app/domain/repositeries/media_attachement_repositories.dart';

class PickMediaUsecase {
  final MediaAttachementRepository _mediaAttachementRepository;
  PickMediaUsecase({required MediaAttachementRepository attacmentRepo})
    : _mediaAttachementRepository = attacmentRepo;

  Future<List<String>> call({
    required NoteMediaSource source,
    required NoteMediaType type,
  }) async {
    return _mediaAttachementRepository.pickMedia(source: source, type: type);
  }
}
