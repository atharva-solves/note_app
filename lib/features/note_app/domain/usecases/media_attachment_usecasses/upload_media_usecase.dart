import 'package:note_app/features/note_app/domain/repositeries/media_attachement_repositories.dart';

class UploadMediaUsecase {
  final MediaAttachementRepository _mediaAttachementRepository;
  UploadMediaUsecase({required MediaAttachementRepository attacmentRepo})
    : _mediaAttachementRepository = attacmentRepo;

  Future<String> call({
    required String mediaLocalPath,
    required String userAuthId,
  }) async {
    return _mediaAttachementRepository.uploadMedia(
      mediaLocalPath: mediaLocalPath,
      userAuthId: userAuthId,
    );
  }
}
