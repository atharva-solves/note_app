import 'package:note_app/features/note_app/data/data_sources/get_storage.dart/note_local_data_sources/note_local_datasource.dart';

import '../../domain/entity/note_entity.dart';
import '../../domain/repositeries/note_repository.dart';

import '../models/note_model.dart';

class GetStorageNoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource _noteLocalDataSource;

  GetStorageNoteRepositoryImpl({
    required NoteLocalDataSource noteLocalDataSource,
  }) : _noteLocalDataSource = noteLocalDataSource;

  @override
Future<void> saveNote(NoteEntity note) async {
  // The domain gives us a NoteEntity.
  // GetStorage does not know anything about NoteEntity,
  // so first convert it into the storage-friendly model.
  final NoteModel noteModel = NoteModel.fromEntity(note);

  final Map<String, dynamic> rawNote = noteModel.toJson();

  // GetStorage keeps all notes together as one stored list.
  // Therefore, read the existing list before adding/updating
  // the current note.
  final List<dynamic> rawData =
      _noteLocalDataSource.getNotesFromStorage() ?? [];

  final List<Map<String, dynamic>> notes =
      rawData.map(
        (item) => Map<String, dynamic>.from(item),
      ).toList();

  // Check whether this note already exists.
  // If it exists, update that entry.
  // Otherwise, add it as a new note.
  final int existingIndex = notes.indexWhere(
    (storedNote) => storedNote['id'] == note.id,
  );

  if (existingIndex == -1) {
    notes.add(rawNote);
  } else {
    notes[existingIndex] = rawNote;
  }

  // The repository has finished preparing the data.
  // The data source now handles the actual GetStorage write.
  await _noteLocalDataSource.saveNotesToStorage(notes);
}

  @override
Stream<List<NoteEntity>> getAllNotes() {
  // GetStorage gives us raw data.
  // The repository is responsible for converting that
  // raw data into objects that the domain layer understands.
  final List<dynamic> rawData =
      _noteLocalDataSource.getNotesFromStorage() ?? [];

  final List<NoteEntity> notes = rawData.map((rawNote) {
    // Storage returns dynamic values, so convert each item
    // into the Map format expected by NoteModel.
    final Map<String, dynamic> noteMap =
        Map<String, dynamic>.from(rawNote);

    return NoteModel.fromJson(noteMap);
  }).toList();

  // GetStorage is not a realtime stream like Firestore.
  // We wrap the current result in a one-time Stream so that
  // this repository can satisfy the same domain contract.
  return Stream.value(notes);
}

  @override
Future<void> deleteNote(String noteId) async {
  // GetStorage stores the complete notes list, so deletion
  // means reading the current list, removing the matching
  // note, and writing the updated list back.
  final List<dynamic> rawData =
      _noteLocalDataSource.getNotesFromStorage() ?? [];

  final List<Map<String, dynamic>> notes =
      rawData.map(
        (item) => Map<String, dynamic>.from(item),
      ).toList();

  notes.removeWhere(
    (storedNote) => storedNote['id'] == noteId,
  );

  // The repository decides what data should be stored.
  // The data source is responsible only for performing the write.
  await _noteLocalDataSource.saveNotesToStorage(notes);
}

   @override
  Future<void> waitForNoteWrites() async {
    
  }

  //clear in ctr signOut after successfully notes pushed/saved online
  @override
  Future<void> clearLocalNoteCache() async {
    
  }

}