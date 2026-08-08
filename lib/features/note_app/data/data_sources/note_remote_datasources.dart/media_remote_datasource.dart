import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class MediaRemoteDatasource {
  Future<String> uploadMedia({
    required String localPath,
    required String userAuthId,
  });
}

class MediaRemoteDatasourceImpl implements MediaRemoteDatasource {
  final SupabaseClient _supabaseClient;
  final String supabaseBucketName = 'note_media';

  MediaRemoteDatasourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  @override
  Future<String> uploadMedia({
    required String localPath,
    required String userAuthId,
  }) async {
    try {
      debugPrint('Media RDS Started');
      //1 extract extension
      final String extension = localPath.split('.').last;

      //2 fileName (DateTime now msEpoch bcz make filepath unguessable)
      final String fileName =
          'media_${DateTime.now().millisecondsSinceEpoch}.$extension';

      //3 folder pat inside cloud supabase bucket storage
      final String storagePath = 'users/$userAuthId/notes_media/$fileName';

      //4 extract dart file from locPath
      final file = File(localPath);

      //5 5save  to bucket
      await _supabaseClient.storage
          .from(supabaseBucketName)
          .upload(storagePath, file);

      //6 get Link
      String publicUrl = _supabaseClient.storage
          .from(supabaseBucketName)
          .getPublicUrl(storagePath);

      debugPrint(
        'Media RDS Successful,single media uploaded passing publicURL to repoImpl',
      );
      return publicUrl;
    } catch (e) {
      debugPrint('MediaRDS>uploadMedia>caught error > $e');
      // If the internet drops or the bucket doesn't exist, we catch the error
      throw Exception('Failed to upload media to Supabase: $e');
    }
  }
}
