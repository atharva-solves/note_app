import 'package:note_app/features/note_app/domain/enums/media_attachment_enums.dart';

class MediaAttachmentNestedEntity {
  final NoteMediaType mediaType;
  final String mediaLink;
  MediaAttachmentNestedEntity({
    required this.mediaType,
    required this.mediaLink,
  });

  //Solution to error:Invalid argument (in map converted from Note) ->instance of MediaAttNesEn
  //fireStore dont know whats a dart obj(MedAttNEnt) is.
  //it only speaks str,int,bool,map
  //Solution:convert medAtt to a map before sending
  Map<String, dynamic> toMap() {
    return {'mediaType': mediaType.name, 'mediaLink': mediaLink};
  }

  //since invalid arg err solved by converting dart obj to map,
  //DB will return L<Map<>>.
  //we need to conv each map to MedAtt before saving to ent
  factory MediaAttachmentNestedEntity.fromJson({
    required Map<String, dynamic> json,
  }) {
    return MediaAttachmentNestedEntity(
      //extract type String
      //return a Enum.option(val) if this string  MATCHES any val(option/type) in Enum
      mediaType: NoteMediaType.values.byName(json['mediaType']),
      mediaLink: json['mediaLink'],
    );
  }
}
