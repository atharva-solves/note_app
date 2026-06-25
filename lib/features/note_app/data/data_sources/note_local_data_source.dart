import 'package:note_app/core/services/local_storage_service.dart';

class NoteLocalDataSource {
  //fields ,fin con priv.

  final StorageService _storageService;
  static const String _noteKey = 'MY_NOTES_DATABASE';

  //constructor , with init List bcz _private
  NoteLocalDataSource({required StorageService storageService})
    : _storageService = storageService;

  //get ,save methods

  dynamic getNotesFromStorage() {
    _storageService.readData(_noteKey);
  }

  Future<void> saveNotesToStorage(List<dynamic> rawNotesList) async {
    await _storageService.writeData(_noteKey, rawNotesList);
  }
}
