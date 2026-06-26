import 'package:note_app/features/note_app/data/models/note_model.dart';
import 'package:note_app/features/note_app/domain/repositeries/note_repository.dart';

class ToggleImportantUsecase {
  final NoteRepository _noteRepository;

  ToggleImportantUsecase({required NoteRepository noteRepository}) : _noteRepository = noteRepository;

  Future<void> execute(String targetID) async {
    List<NoteModel> currentNotes = _noteRepository.getNotes();

    final int index = currentNotes.indexWhere((note) => note.id == targetID);

    if (index != -1) {
      final oldNote = currentNotes[index];
      final updatedNote = oldNote.copyWith(isImportant: !oldNote.isImportant);

      currentNotes[index] = updatedNote;

      await _noteRepository.saveNotes(currentNotes);
    }
  }
}
