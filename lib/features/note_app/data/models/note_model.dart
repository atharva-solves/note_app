class NoteModel {
  final String id;
  final String title;
  final String content;
  final String createdAt;
  final bool isImportant; // 🔥 Added for the IMP note marking feature

  // 1. The Standard Constructor
  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isImportant,
  });

  // 2. 📥 FROM JSON: Converts raw map data from the hard drive back into a Dart Object
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Note',
      content: json['content']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? DateTime.now().toString(),
      isImportant: json['is_important'] as bool? ?? false, // Safe fallback default value
    );
  }

  // 3. 📤 TO JSON: Converts our Dart Object into a raw Map format so GetStorage can write it to disk
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt,
      'is_important': isImportant,
    };
  }

  // 4. 🔄 COPY WITH: An industry-standard pattern used to modify a single field (like isImportant) safely
  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? createdAt,
    bool? isImportant,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isImportant: isImportant ?? this.isImportant,
    );
  }
}