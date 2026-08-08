import 'package:flutter/material.dart';
import 'package:note_app/core/services/local_storage_service.dart';
// NoteEntity import removed! LDS shouldn't know about Entities.

class NoteLocalStorageDataSource {
  final StorageService _storageService;
  static const String _noteKey = 'MY_NOTES_DATABASE';

  NoteLocalStorageDataSource({required StorageService storageService})
    : _storageService = storageService;

  // FIX: Changed return type to List<dynamic>? because it reads raw JSON from storage
  List<dynamic>? getNotesFromStorage() {
    try {
      return _storageService.readData(_noteKey);
    } catch (e) {
      debugPrint("note_app>data>note_local_data_source>getNotes : ERROR ==> $e");
      rethrow;
    }
  }

  Future<void> saveNotesToStorage(List<Map<String,dynamic>> rawNotesList) async {
    try {
      if (rawNotesList.isNotEmpty) {
        debugPrint(
          'LDS -> saveNotesToStorage -> Latest note title is -> ${rawNotesList[0]['title']}',
        ); 
      }
      await _storageService.writeData(_noteKey, rawNotesList);
    } catch (e) {
      debugPrint("note_app>data>note_local_data_source>saveNotes : ERROR ==> $e");
      rethrow;
    }
  }
}