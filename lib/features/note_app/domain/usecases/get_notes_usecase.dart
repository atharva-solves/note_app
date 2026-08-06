import 'package:note_app/features/note_app/domain/entity/note_entity.dart';
import 'package:note_app/features/note_app/domain/repositeries/note_repository.dart';

class GetNotesUsecase {
  //UC<--only talks to-->Repo (abstract boss)
  //fin var (instance),constr,meth

  final NoteRepository _noteRepository;

  //contructor
  GetNotesUsecase({required NoteRepository noteRepository})
    : _noteRepository = noteRepository;

  //-----------Get Storage --------------
  /*  //actual method
  List<NoteEntity> execute() => noteRepository.getNotes(); */


//------------ Note Remote D S (FireStore) ------------
  Stream<List<NoteEntity>> call()  {
    return  _noteRepository.getAllNotes();
  }
}
