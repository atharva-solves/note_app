import 'package:note_app/features/note_app/data/data_sources/note_local_data_sources/media_local_datasource.dart';
import 'package:note_app/features/note_app/data/data_sources/note_remote_datasources.dart/media_remote_datasource.dart';
import 'package:note_app/features/note_app/domain/enums/media_attachment_enums.dart';
import 'package:note_app/features/note_app/domain/repositeries/media_attachement_repositories.dart';

class MediaAttachmentRepositoryImpl implements MediaAttachementRepository {
  final MediaLocalDatasource _mediaLocalDatasource;
  final MediaRemoteDatasource _mediaRemoteDatasource;

  MediaAttachmentRepositoryImpl({
    required MediaLocalDatasource mediaLocalDatasource,
    required MediaRemoteDatasource mediaRemoteDatasource,
  }) : _mediaLocalDatasource = mediaLocalDatasource,
       _mediaRemoteDatasource = mediaRemoteDatasource;

  @override
  Future<List<String>> pickMedia({
    required NoteMediaSource source,
    required NoteMediaType type,
  }) async {
    return await _mediaLocalDatasource.pickMedia(
      mediaSource: source,
      mediaType: type,
    );
  }

  @override
  Future<List<String>> uploadMultipleMedia({
    required List<String> mediaLocalPaths,
    required String userAuthId,
  }) async {
    //chef(rDS) handling order tickets to Waiter(Future)
    //to  (.map) (since map doesnt wait for food[media upload task] to be made completely)
    //faster that for in loop bcz all tasks are being completed at once
    List<Future<String>> uploadTasks = mediaLocalPaths.map((localPath) {
      return _mediaRemoteDatasource.uploadMedia(
        localPath: localPath,
        userAuthId: userAuthId,
      );
    }).toList();

    //wait for food tobe made (upload hughe binary file to db)
    //return actual food(List<Strings>) to customer(repo)
    final List<String> cloudUrls = await Future.wait(uploadTasks);

    return cloudUrls;
  }

  //future proof usecase (example profile avatar only one profpic upload)
  @override
  Future<String> uploadMedia({
    required String mediaLocalPath,
    required String userAuthId,
  }) async {
    return await _mediaRemoteDatasource.uploadMedia(
      localPath: mediaLocalPath,
      userAuthId: userAuthId,
    );
  }
}
