import 'package:note_app/features/note_app/domain/repositeries/media_attachement_repositories.dart';

class UploadMultipleMediaUsecase {
  final MediaAttachementRepository _mediaAttachementRepository;
  UploadMultipleMediaUsecase({required MediaAttachementRepository mediaAttachRepo})
    : _mediaAttachementRepository = mediaAttachRepo;

  Future<List<String>> call({
    required List<String> mediaLocalPaths,
    required String userAuthId,
  }) async {
    return await _mediaAttachementRepository.uploadMultipleMedia(
      mediaLocalPaths: mediaLocalPaths,
      userAuthId: userAuthId,
    );
  }
}
