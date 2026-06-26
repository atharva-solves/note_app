import 'package:get/get.dart';
import 'package:note_app/features/note_app/data/models/note_model.dart';
import 'package:note_app/features/note_app/domain/usecases/add_note_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/delete_note_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/get_notes_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/toggle_important_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/update_note_usecase.dart';

class NoteController extends GetxController {
  //1.fin _ fields (UCs)
  //2.constr with init list
  //3.reactive var List
  //4.onInit to load
  //5. meths (UCs) (Actn -> Exec -> reload)

  final AddNoteUsecase _addNoteUsecase;
  final GetNotesUsecase _getNotesUsecase;
  final UpdateNoteUsecase _updateNoteUsecase;
  final DeleteNoteUsecase _deleteNoteUsecase;
  final ToggleImportantUsecase _toggleImportantUsecase;

  NoteController({
    required AddNoteUsecase addNoteUsecase,
    required GetNotesUsecase getNotesUsecase,
    required UpdateNoteUsecase updateNoteUsecase,
    required DeleteNoteUsecase deleteNoteUsecase,
    required ToggleImportantUsecase toggleImportantUsecase,
  }) : _addNoteUsecase = addNoteUsecase,
       _getNotesUsecase = getNotesUsecase,
       _updateNoteUsecase = updateNoteUsecase,
       _deleteNoteUsecase = deleteNoteUsecase,
       _toggleImportantUsecase = toggleImportantUsecase;

  RxList<NoteModel> noteList = <NoteModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  //UI Action 1:Read
  void loadNotes() {
    final notes = _getNotesUsecase.execute();
    noteList.value = notes;
  }

  //UI Action 2: Create
  Future<void> addNote(NoteModel note) async {
    await _addNoteUsecase.execute(note);
    loadNotes();
  }

  //UI Action 3:Update
  Future<void> updateNote(NoteModel updatedNote) async {
    await _updateNoteUsecase.execute(updatedNote);
    loadNotes();
  }

  //UI Action 4:Delete a note
  Future<void> deleteNote(String noteId) async {
    await _deleteNoteUsecase.execute(noteId);
    loadNotes();
  }

  //UI Action 5:Toggle IMP
  Future<void> toggleImportant(String noteId) async {
    await _toggleImportantUsecase.execute(noteId);
    loadNotes();
  }
}
