import 'package:note_app/features/note_app/domain/repositeries/media_attachement_repositories.dart';

class DeleteMediaUsecase {
  final MediaAttachementRepository _mediaAttachementRepository;
  DeleteMediaUsecase({
    required MediaAttachementRepository mediaAttachementRepository,
  }) : _mediaAttachementRepository = mediaAttachementRepository;

  Future<void> call({required List<String> publicUrls}) async {
    return await _mediaAttachementRepository.deleteMedia(
      publicUrls: publicUrls,
    );
  }
}
