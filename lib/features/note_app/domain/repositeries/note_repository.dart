//contract of rules,
//(ctr,UI : models)<--Repo-->(local storage:maps)
import 'package:note_app/features/note_app/domain/entity/note_entity.dart';

abstract class NoteRepository {
  //rule 1 must fetch list in NoteModel
  List<NoteEntity> getNotes();

  //rule 2 must save list of models in storage
  Future<void> saveNotes(List<NoteEntity> notesList);
}
