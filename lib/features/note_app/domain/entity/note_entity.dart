// lib/features/note_app/domain/entity/note_entity.dart

import 'package:note_app/features/note_app/domain/entity/nested_entities/media_attachment_nested_entity.dart';

class NoteEntity {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isImportant;

  //solution : Nested Entities , Many to one relationship.
  final List<MediaAttachmentNestedEntity> mediaAttacments;

  //CHANGED PLAN to support multiple media and type per Note
  /* //to store cloud storage web link of img/vid
  final String? mediaUrl;

  //to store type (vid/img)
  final String? mediaType; */

  NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isImportant,
    required this.userId,
    this.mediaAttacments = const [],
  });
  NoteEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? createdAt,
    bool? isImportant,
    List<MediaAttachmentNestedEntity>? mediaAttachments,
  }) {
    return NoteEntity(
      // If a new value is provided, use it. Otherwise, fall back to 'this' value.
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isImportant: isImportant ?? this.isImportant,
      mediaAttacments: mediaAttacments,
    );
  }
}
