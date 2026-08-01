import 'package:flutter/foundation.dart';
import 'package:note_app/features/note_app/domain/entity/note_entity.dart';
import 'package:note_app/features/note_app/domain/repositeries/note_repository.dart';

class AddNoteUsecase {
  //fin var (ins),construct,meth

  final NoteRepository _noteRepository;

  AddNoteUsecase({required NoteRepository noteRepository})
    : _noteRepository = noteRepository;

  Future<void> execute(NoteEntity noteEntity) async {
    final List<NoteEntity> currentList = _noteRepository.getNotes();

    debugPrint('AddNoteUC -> execute  -> note title is -> ${noteEntity.title}');
    currentList.insert(0, noteEntity);

    //(- of GetStor) Fetch list , do action , and save entire list Every time
    //unlike SQL :modify that specific data directly in DB.
    await _noteRepository.saveNotes(currentList);
  }
}
