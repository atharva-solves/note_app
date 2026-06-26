import 'package:note_app/features/note_app/data/models/note_model.dart';
import 'package:note_app/features/note_app/domain/repositeries/note_repository.dart';

class UpdateNoteUsecase {
  final NoteRepository _noteRepository;
  UpdateNoteUsecase({required NoteRepository noteRepository}) : _noteRepository = noteRepository;

  Future<void> execute(NoteModel updatedNote) async {
    final List<NoteModel> currentNotes = _noteRepository.getNotes();

    final int index = currentNotes.indexWhere(
      (note) => note.id == updatedNote.id,
    );

    if (index != -1) {
      currentNotes[index] = updatedNote;

      await _noteRepository.saveNotes(currentNotes);
    }
  }
}
