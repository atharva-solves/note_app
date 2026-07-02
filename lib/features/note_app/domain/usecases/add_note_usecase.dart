import 'package:note_app/features/note_app/data/models/note_model.dart';
import 'package:note_app/features/note_app/domain/repositeries/note_repository.dart';

class AddNoteUsecase {
  //fin var (ins),construct,meth

  final NoteRepository _noteRepository;

  AddNoteUsecase({required NoteRepository noteRepository}) : _noteRepository = noteRepository;

  Future<void> execute(NoteModel noteModel) async {
    final List<NoteModel> currentList = _noteRepository.getNotes();
    
    
    print('AddNoteUC -> execute  -> note title is -> ${noteModel.title}');
    currentList.insert(0, noteModel);

//(- of GetStor) Fetch list , do action , and save entire list Every time
//unlike SQL :modify that specific data directly in DB.
    await _noteRepository.saveNotes(currentList);
  }
}
