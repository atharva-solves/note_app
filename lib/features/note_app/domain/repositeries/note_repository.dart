//contract of rules,
//(ctr,UI : models)<--Repo-->(local storage:maps)
import 'package:note_app/features/note_app/domain/entity/note_entity.dart';

abstract class NoteRepository {
  // --------------- Note Local Data Storage -------------
  /* 
  //rule 1 must fetch list in NoteModel
  List<NoteEntity> getNotes();


  //rule 2 must save list of models in storage
  Future<void> saveNotes(List<NoteEntity> notesList);
*/
  // --------------- Note Cloud Data Storage -------------

  //save single one note at time , not complete list unlike get Storage
  Future<void> saveNotes(NoteEntity note);
  //return Futue
  Stream<List<NoteEntity>> getAllNotes();

  //seperate delete operation for single note
  Future<void> deleteNote(String noteId);

  //check User Offline (if waiting For Pending offline notes(FireStore Off feat) took more than 3 seconds)
  Future<void> waitForNoteWrites();

  //clear if online (waiting stoped before 3 sec->notes stored online->clear offline cache [bcz we need to signout]).
  Future<void> clearLocalNoteCache();
}
