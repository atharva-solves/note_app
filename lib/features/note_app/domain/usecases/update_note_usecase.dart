/* import 'package:note_app/features/note_app/domain/entity/note_entity.dart';
import 'package:note_app/features/note_app/domain/repositeries/note_repository.dart';


//--------Note LDS (Get Storage)--------------
//-------- add note/save note is already upsert. so no need seperate firestore Update UC.
class UpdateNoteUsecase {
  final NoteRepository _noteRepository;
  UpdateNoteUsecase({required NoteRepository noteRepository})
    : _noteRepository = noteRepository;

  Future<void> execute(NoteEntity updatedNote) async {
    final List<NoteEntity> currentNotes = _noteRepository.getNotes();

    final int index = currentNotes.indexWhere(
      (note) => note.id == updatedNote.id,
    );

    if (index != -1) {
      currentNotes[index] = updatedNote;

      await _noteRepository.saveNotes(currentNotes);
    }
  }
}
 */