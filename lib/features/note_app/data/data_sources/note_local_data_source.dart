import 'package:note_app/core/services/local_storage_service.dart';

//this is not core now, it gets feature specific.
//W H Y ?:
//1 switch to a different database service called Hive.
//2 The Testing Superpower (Mocking)
//3 Memory Efficiency (Single Source of Truth)

class NoteLocalDataSource {
  //fields ,fin con priv.
  final StorageService _storageService;
  static const String _noteKey = 'MY_NOTES_DATABASE';

  //constructor , with init List bcz _private
  NoteLocalDataSource({required StorageService storageService})
    : _storageService = storageService;

  //get ,save methods

  //added return to pass data back successfully
  dynamic getNotesFromStorage() {
    return _storageService.readData(_noteKey);
  }

  Future<void> saveNotesToStorage(List<dynamic> rawNotesList) async {
    if (rawNotesList.isNotEmpty) {
      // Safe check before printing
      print(
        'LDS -> saveNotesToStorage -> Latest note title is -> ${rawNotesList[0]['title']}',
      ); // ✅ Map syntax
    }
    await _storageService.writeData(_noteKey, rawNotesList);
  }
}
