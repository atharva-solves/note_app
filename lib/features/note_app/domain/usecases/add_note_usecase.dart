import 'package:note_app/features/note_app/data/models/note_model.dart';
import 'package:note_app/features/note_app/domain/repositeries/note_repository.dart';

class AddNoteUsecase {
  //fin var (ins),construct,meth

  final NoteRepository _noteRepository;

  AddNoteUsecase({required NoteRepository noteRepository}) : _noteRepository = noteRepository;

  Future<void> execute(NoteModel noteModel) async {
    final List<NoteModel> currentList = _noteRepository.getNotes();

    currentList.insert(0, noteModel);

    await _noteRepository.saveNotes(currentList);
  }
}
