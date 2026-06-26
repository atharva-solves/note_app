//contract of rules,
//(ctr,UI : models)<--Repo-->(local storage:maps)
import 'package:note_app/features/note_app/data/models/note_model.dart';

abstract class NoteRepository {
  //rule 1 must fetch list in NoteModel
  List<NoteModel> getNotes();

  //rule 2 must save list of models in storage
  Future<void> saveNotes(List<NoteModel> notesList);
}
