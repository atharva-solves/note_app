import 'package:flutter/cupertino.dart';
import 'package:note_app/features/note_app/data/models/note_model.dart';
import 'package:note_app/features/note_app/domain/repositeries/note_repository.dart';

class DeleteNoteUsecase {
  final NoteRepository _noteRepository;

  DeleteNoteUsecase({required NoteRepository noteRepository}) : _noteRepository = noteRepository;

  Future<void> execute(String targetID) async {
    List<NoteModel> currentList = _noteRepository.getNotes();

    currentList.removeWhere((note) => note.id == targetID);

    await _noteRepository.saveNotes(currentList);
  }
}
