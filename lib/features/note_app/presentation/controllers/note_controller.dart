import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:note_app/features/note_app/domain/entity/note_entity.dart';
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

  RxList<NoteEntity> noteList = <NoteEntity>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  //solved ghost Ref bug
  //remove loadNotes() from onInit
  //add in onReady
  //with delay for 100% gaurantee for old devices
  //so change is noted by RxList

  //comment out for mocking

  @override
  void onReady() {
    super.onReady();
    if (noteList.isNotEmpty) {
      debugPrint(
        'noteCtrl -> onReady -> note title os latest note is is -> ${noteList[0].title}',
      );
    }
    Future.delayed(Duration(milliseconds: 100), () => loadNotes());
  }

  //mocking NoteView
  /*  @override
  void onReady() {
    super.onReady();

    Future.delayed(const Duration(milliseconds: 100), () {
      //  TEMPORARY DUMMY DATA FOR UI TESTING 
      noteList.assignAll([
        NoteEntity(
          id: '1',
          title: 'Grocery List',
          content:
              'Almond milk, eggs, whole wheat bread, and spinach for the week.',
          createdAt: DateTime.now().toIso8601String(),
          isImportant: false,
        ),
        NoteEntity(
          id: '2',
          title: 'App Ideas',
          content:
              'A clean architecture note taking app with a Gen-Z minimalist aesthetic. Must use GetX.',
          createdAt: DateTime.now().toIso8601String(),
          isImportant: true,
        ),
        NoteEntity(
          id: '3',
          title: '', // Testing what happens if title is empty
          content:
              'This note has no title, just some random thoughts and musings for the day.',
          createdAt: DateTime.now().toIso8601String(),
          isImportant: false,
        ),
      ]);

      // COMMENT OUT THE REAL DATABASE CALL FOR NOW
      // loadNotes();
    });
  } */

  //UI Action 1:Read
  void loadNotes() {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final notes = _getNotesUsecase.execute();
      noteList.value = notes;
    } catch (e) {
      debugPrint("note_app>pres>controller>loadNotes : ERROR ==> $e");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  //UI Action 2: Create
  Future<void> addNote(NoteEntity note) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _addNoteUsecase.execute(note);
      debugPrint('noteCtrl -> addNote -> note title is -> ${note.title}');
      loadNotes();
    } catch (e) {
      debugPrint("note_app>pres>controller>addNotes : ERROR ==> $e");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  //UI Action 3:Update
  Future<void> updateNote(NoteEntity updatedNote) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _updateNoteUsecase.execute(updatedNote);
      loadNotes();
    } catch (e) {
      debugPrint("note_app>pres>controller>updateNotes : ERROR ==> $e");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  //UI Action 4:Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _deleteNoteUsecase.execute(noteId);
      loadNotes();
    } catch (e) {
      debugPrint("note_app>pres>controller>deleteNotes : ERROR ==> $e");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  //UI Action 5:Toggle IMP
  Future<void> toggleImportant(String noteId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _toggleImportantUsecase.execute(noteId);
      loadNotes();
    } catch (e) {
      debugPrint("note_app>pres>controller>toggleImportant : ERROR ==> $e");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
