//for timeOut 
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:note_app/features/auth/domain/usecases/email_pass_auth_usecases/sign_out_usecase.dart';
import 'package:note_app/features/note_app/domain/entity/note_entity.dart';
import 'package:note_app/features/note_app/domain/usecases/add_note_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/delete_note_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/fireStore_offline_feat_usecases/clearNotesLocalCache.dart';
import 'package:note_app/features/note_app/domain/usecases/fireStore_offline_feat_usecases/waitForNotesWrite.dart';
import 'package:note_app/features/note_app/domain/usecases/get_notes_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/toggle_important_usecase.dart';
import 'package:note_app/features/note_app/presentation/widgets/unsaved_changes_dialog.dart';

class NoteController extends GetxController {
  //1.fin _ fields (UCs)
  //2.constr with init list
  //3.reactive var List
  //4.onInit to load
  //5. meths (UCs) (Actn -> Exec -> reload)

  final AddNoteUsecase _addNoteUsecase;
  final GetNotesUsecase _getNotesUsecase;
  //since upsert in firestore, there fore no use in RDS
  //final UpdateNoteUsecase _updateNoteUsecase;
  final DeleteNoteUsecase _deleteNoteUsecase;
  final ToggleImportantUsecase _toggleImportantUsecase;

  //Integrating FireStor Offline Feature
  //warn user before signOut (FS offline limitation : discard edits on auth current user change)
  final WaitfornoteswriteUsecase _waitfornoteswriteUsecase;
  final ClearnoteslocalcacheUseCase _clearnoteslocalcacheUseCase;
  final SignOutUsecase _signOutUsecase;

  NoteController({
    required AddNoteUsecase addNoteUsecase,
    required GetNotesUsecase getNotesUsecase,
    //required UpdateNoteUsecase updateNoteUsecase,
    required DeleteNoteUsecase deleteNoteUsecase,
    required ToggleImportantUsecase toggleImportantUsecase,
    required WaitfornoteswriteUsecase waitfornoteswriteUsecase,
    required ClearnoteslocalcacheUseCase clearnoteslocalcacheUseCase,
    required SignOutUsecase signOutUsecase,
  }) : _waitfornoteswriteUsecase = waitfornoteswriteUsecase,
       _clearnoteslocalcacheUseCase = clearnoteslocalcacheUseCase,
       _signOutUsecase = signOutUsecase,
       _addNoteUsecase = addNoteUsecase,
       _getNotesUsecase = getNotesUsecase,
       // _updateNoteUsecase = updateNoteUsecase,
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

    //now the getNotes usecase is a Stream , so no need to every time manually call loadNotes
    //just attach RxList var to getNotesUC onReady.

    noteList.bindStream(_getNotesUsecase());

    //attached stream to RxList
    //no need to manually loadnotes
    //noteUpdated-->stream attached to RxList-->if old vs new diff then RxList is updated

    //fireStore Stream (.snapShot Tootks time)
    //Future.delayed(Duration(milliseconds: 100), () => loadNotes());
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

  //UI SignOut Action:
  Future<void> noteViewSignOut() async {
    try {
      //start Loading spinner
      //dialog -> like nav to new screen
      //if want to close -> get Back to previous screen
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      //we already tapped save Note button in edit Note view
      //fireStore constantly waiting for connection and trying to push notes
      //save in RDB as soon as reconnect
      await _waitfornoteswriteUsecase();

      //we waited-->if notes Pushed ,online ,
      //#_clearlocal Persistance , #_signout ,#(get back)close Loading Spinner
      await _clearnoteslocalcacheUseCase();
      await _signOutUsecase();

      //if more that 3 sec--> timeOut Exception
    } on TimeoutException {
      debugPrint("NoteController > signOut : TIMEOUT (User is offline)");
      Get.back(); // Close loading indicator

      // Show warning dialog
      _showUnsavedOfflineWarnDialog();
    } catch (e) {
      debugPrint("NoteController > signOut : ERROR ==> $e");
      Get.back();
      errorMessage.value = e.toString();
    }
  }

  //warning
  //on TimeOut-> user is offline and trying to signout without edit save
  void _showUnsavedOfflineWarnDialog() {
    Get.dialog(const UnsavedChangesDialog());
  }

  //since custom widget made to get rid of UI in Ctrl (Clean Arch)
  //there it will call force signout method on force signout button
  Future<void> forceSignOut() async {
    try {
      isLoading.value = true;
      await _clearnoteslocalcacheUseCase();
      await _signOutUsecase();
    } catch (e) {
      debugPrint("NoteController > forceSignOut : ERROR ==> $e");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  //UI Action 1:Read

  /////--------------RDS (FireStore)----------
  /*  Future<void> loadNotes() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final notes = await _getNotesUsecase();
      noteList.assignAll(notes);
    } catch (e) {
      debugPrint("note_app>pres>controller>loadNotes : ERROR ==> $e");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  } */

  //----------------LDS Get Storage----------
  /* void loadNotes() {
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
  } */
  //----------------Load Notes From Getstorage ENDS---------------

  //UI Action 2: Create
  Future<void> saveNote(NoteEntity note) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      //just direct() bcz of call in UC ---FOR RDS FireStore
      await _addNoteUsecase(note);
      debugPrint('noteCtrl -> addNote -> note title is -> ${note.title}');

      //attached stream to RxList
      //no need to manually loadnotes
      //noteUpdated-->stream attached to RxList-->if old vs new diff then RxList is updated
      //loadNotes();
    } catch (e) {
      debugPrint("note_app>pres>controller>addNotes : ERROR ==> $e");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  //UI Action 3:Update

  //No need for RDS Firestore  bcs Upsert (saveNotes) docRef.set()
  /*  Future<void> updateNote(NoteEntity updatedNote) async {
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
 */
  //UI Action 4:Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      //Direct () .No need of exec bcz call in UC
      //RDS FireStore
      await _deleteNoteUsecase(noteId);

      //attached stream to RxList
      //no need to manually loadnotes
      //noteUpdated-->stream attached to RxList-->if old vs new diff then RxList is updated
      //loadNotes();
    } catch (e) {
      debugPrint("note_app>pres>controller>deleteNotes : ERROR ==> $e");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  //UI Action 5:Toggle IMP
  //pass Entity for FireStore RDS
  Future<void> toggleImportant(NoteEntity noteEntity) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      //Need to pass Entity for RDS FireStore
      await _toggleImportantUsecase(noteEntity: noteEntity);
      //await _toggleImportantUsecase.execute(noteId);

      //attached stream to RxList
      //no need to manually loadnotes
      //noteUpdated-->stream attached to RxList-->if old vs new diff then RxList is updated
      //loadNotes();
    } catch (e) {
      debugPrint("note_app>pres>controller>toggleImportant : ERROR ==> $e");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
