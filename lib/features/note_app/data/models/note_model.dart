import 'package:note_app/features/note_app/domain/entity/note_entity.dart';

class NoteModel extends NoteEntity {
  NoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.isImportant,
  });

  // 1. JSON Deserialization (Map -> Model)
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      // JSON doesn't understand DateTime, so we parse the String back into a DateTime object
      createdAt: DateTime.parse(json['createdAt'] as String),
      isImportant: json['isImportant'] as bool,
    );
  }

  // 2. JSON Serialization (Model -> Map)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      // Convert the DateTime object into a JSON-friendly String
      'createdAt': createdAt.toIso8601String(),
      'isImportant': isImportant,
    };
  }

  // 3. The Bridge (Entity -> Model)
  // Used in your Repository when saving data from the UI down to the database
  factory NoteModel.fromEntity(NoteEntity entity) {
    return NoteModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      createdAt: entity.createdAt,
      isImportant: entity.isImportant,
    );
  }
}