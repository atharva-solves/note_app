// lib/features/note_app/domain/entity/note_entity.dart

class NoteEntity {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isImportant;

  NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isImportant,
  });
  NoteEntity copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    bool? isImportant,
  }) {
    return NoteEntity(
      // If a new value is provided, use it. Otherwise, fall back to 'this' value.
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isImportant: isImportant ?? this.isImportant,
    );
  }
}
