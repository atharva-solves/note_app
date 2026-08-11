import 'package:note_app/features/note_app/domain/entity/nested_entities/media_attachment_nested_entity.dart';
import 'package:note_app/features/note_app/domain/entity/note_entity.dart';

class NoteModel extends NoteEntity {
  NoteModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.isImportant,
    required super.mediaAttachments,
  });

  // 1. JSON Deserialization (Map -> Model)
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,

      // JSON doesn't understand DateTime, so we parse the String back into a DateTime object
      createdAt: DateTime.parse(json['createdAt'] as String),
      isImportant: json['isImportant'] as bool,
      // Used in your Repository when saving data from the UI down to the FireStore NoteRDS database
      //### ADDED NULL CHECK bcz old notes (before attachment feat doesnt have medAtt arg)
      //there fore null check eventhough new entity has this.medAtt=[] fallBack
      //if not null=> listOfMedAtt :or if null then [] 
      mediaAttachments: json['mediaAttachments'] != null
          ? (json['mediaAttachments'] as List)
                .map((json) => MediaAttachmentNestedEntity.fromJson(json: json))
                .toList()
          : [],
    );
  }

  // 2. JSON Serialization (Model -> Map)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      // Convert the DateTime object into a JSON-friendly String
      'createdAt': createdAt.toIso8601String(),
      'isImportant': isImportant,
      //take list of MedAtt, map it, convert each medAtt toJson before Sending to fireStore
      'mediaAttachments': mediaAttachments
          .map((attachment) => attachment.toMap())
          .toList(),
    };
  }

  // 3. The Bridge (Entity -> Model)

  factory NoteModel.fromEntity(NoteEntity entity) {
    return NoteModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      content: entity.content,
      createdAt: entity.createdAt,
      isImportant: entity.isImportant,
      //firestore List<Json>-----> map List-->convert each json to MedAtt dartObj->store list<medAtt> in noteEntity
      mediaAttachments: entity.mediaAttachments,
    );
  }
}
