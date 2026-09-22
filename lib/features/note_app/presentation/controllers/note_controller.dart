//for timeOut
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'; // NEW CHANGE: Added for user auth ID in saveCurrentNote
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/features/auth/domain/usecases/email_pass_auth_usecases/sign_out_usecase.dart';
import 'package:note_app/features/note_app/domain/entity/nested_entities/media_attachment_nested_entity.dart';
import 'package:note_app/features/note_app/domain/entity/note_entity.dart';
import 'package:note_app/features/note_app/domain/enums/media_attachment_enums.dart';
import 'package:note_app/features/note_app/domain/usecases/add_note_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/delete_note_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/fireStore_offline_feat_usecases/clearNotesLocalCache.dart';
import 'package:note_app/features/note_app/domain/usecases/fireStore_offline_feat_usecases/waitForNotesWrite.dart';
import 'package:note_app/features/note_app/domain/usecases/get_notes_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/media_attachment_usecasses/delete_media_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/media_attachment_usecasses/pick_media_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/media_attachment_usecasses/upload_multiple_media_usecase.dart';
import 'package:note_app/features/note_app/domain/usecases/toggle_important_usecase.dart';
import 'package:note_app/features/note_app/presentation/widgets/unsaved_changes_dialog.dart';

class NoteController extends GetxController {
  //1.fin _ fields (UCs)
  //2.constr with init list
  //3.reactive var List
  //4.onInit to load
  //5. meths (UCs) (Actn -> Exec -> reload)
  final AddNoteUsecase _saveNoteUsecase;
  final GetNotesUsecase _getNotesUsecase;
  //since upsert in firestore, there fore no use in RDS
  //final UpdateNoteUsecase _updateNoteUsecase;
  final DeleteNoteUsecase _deleteNoteUsecase;
  final ToggleImportantUsecase _toggleImportantUsecase;

  //Integrating FireStor Offline Feature
  //warn user before signOut (FS offline limitation : discard edits on auth current user change)
  final WaitfornoteswriteUsecase _waitfornoteswriteUsecase;
  final ClearNotesLocalCacheUseCase _clearnoteslocalcacheUseCase;
  final SignOutUsecase _signOutUsecase;

  //meadia attacment sub feat
  //action :1.creat and Read
  final PickMediaUsecase _pickMediaUsecase;
  final UploadMultipleMediaUsecase _uploadMultipleMediaUsecase;
  final DeleteMediaUsecase _deleteMediaUsecase;

  // NEW CHANGE: Controllers for Title & Content held inside NoteController so UI can be StatelessWidget
  // late :only init when actually page/view is opened(init).
  late TextEditingController titleController;
  late TextEditingController contentController;

  // NEW CHANGE: Hold currentNote reference inside controller
  // arg receive
  // remove 'final' because if this starts as 'null',
  // due to (constantly listen and save business logic)
  // it will transform into a real note the second the user types a letter!
  NoteEntity? currentNote;

  NoteController({
    required AddNoteUsecase addNoteUsecase,
    required GetNotesUsecase getNotesUsecase,
    //required UpdateNoteUsecase updateNoteUsecase,
    required DeleteNoteUsecase deleteNoteUsecase,
    required ToggleImportantUsecase toggleImportantUsecase,
    required WaitfornoteswriteUsecase waitfornoteswriteUsecase,
    required ClearNotesLocalCacheUseCase clearnoteslocalcacheUseCase,
    required SignOutUsecase signOutUsecase,
    required PickMediaUsecase pickMediaUsecase,
    required UploadMultipleMediaUsecase uploadMultipleMediaUsecase,
    required DeleteMediaUsecase deleteMediaUsecase,
  }) : _deleteMediaUsecase = deleteMediaUsecase,
       _pickMediaUsecase = pickMediaUsecase,
       _uploadMultipleMediaUsecase = uploadMultipleMediaUsecase,
       _waitfornoteswriteUsecase = waitfornoteswriteUsecase,
       _clearnoteslocalcacheUseCase = clearnoteslocalcacheUseCase,
       _signOutUsecase = signOutUsecase,
       _saveNoteUsecase = addNoteUsecase,
       _getNotesUsecase = getNotesUsecase,
       // _updateNoteUsecase = updateNoteUsecase,
       _deleteNoteUsecase = deleteNoteUsecase,
       _toggleImportantUsecase = toggleImportantUsecase;

  RxList<NoteEntity> noteList = <NoteEntity>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  //#media attachment subfeature
  //first save local Media paths for USER PREVIEW
  RxList<String> selectedLocalMediaPaths = <String>[].obs;

  //store previously uploaded cloud media
  //to implement unified(prev+local pick) attachment list
  //~~1.1
  RxList<MediaAttachmentNestedEntity> currentCloudMedia =
      <MediaAttachmentNestedEntity>[].obs;

  List<String> cloudPathsToDelete = [];

  // NEW CHANGE: Initialize TextEditingControllers on controller lifecycle init
  @override
  void onInit() {
    super.onInit();
    titleController = TextEditingController();
    contentController = TextEditingController();
  }

  // Death ! clear ram when view is LEFT
  // NEW CHANGE: Clean up controllers on controller lifecycle close
  @override
  void onClose() {
    // auto deletes listner
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }

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
      debugPrint(
        '<><><><><><>onReady of NoteCtr,now contains ${currentCloudMedia.length} previous media  attachments <><><><><><><>>',
      );
    }
    //now the getNotes usecase is a Stream , so no need to every time manually call loadNotes
    //just attach RxList var to getNotesUC onReady.
    noteList.bindStream(_getNotesUsecase()); //attached stream to RxList
    //no need to manually loadnotes
    //noteUpdated-->stream attached to RxList-->if old vs new diff then RxList is updated
    //fireStore Stream (.snapShot Tootks time)
    //Future.delayed(Duration(milliseconds: 100), () => loadNotes());
  }

  //~~1.2 call this before nav to Edit note
  //~~ clear the previous state
  void setupNoteForEditing({NoteEntity? note}) {
    // NEW CHANGE: Receive note argument & update text fields from controller
    currentNote = note;
    // fill if note exist else empty str
    titleController.text = currentNote != null ? currentNote!.title : '';
    contentController.text = currentNote != null ? currentNote!.content : '';

    selectedLocalMediaPaths.clear();
    if (note != null && note.mediaAttachments.isNotEmpty) {
      //checking wether previous media attachments are inserted
      debugPrint('Setting upNote for Edit View');
      debugPrint('its an existing note with Attachments not Empty');
      debugPrint('assigning media att of this tapped note to currCloudMedia');
      debugPrint(
        '<><><><> existing note has ${note.mediaAttachments.length} attachments',
      );
      currentCloudMedia.assignAll(note.mediaAttachments);
    } else {
      currentCloudMedia.clear();
    }
  }

  // NEW CHANGE: Moved `_saveNote` logic completely into `NoteController` to keep UI dumb
  // runs on every change for local DS Get Storage ,its fast and free
  // auto save -->save Notes for RDS FireStore, limited R/W access. takes time.
  Future<void> saveCurrentNote() async {
    try {
      // extract String from ctrl
      isLoading.value = true;
      errorMessage.value = '';
      final String currentTitle = titleController.text;
      final String currentContent = contentController.text;
      final String userAuthId = FirebaseAuth.instance.currentUser!.uid;

      // Gaurd Clause.gaurd us from running actions if the note is EMPTY.and
      // Soc 1.validation 1.Actions
      // let Back buttons handle the deleting action
      if (currentTitle.trim().isEmpty &&
          currentContent.trim().isEmpty &&
          currentCloudMedia.isEmpty &&
          selectedLocalMediaPaths.isEmpty) {
        return;
      }

      // Soc .Actions A.If new note,ADD(create) else B.Update
      if (currentNote == null) {
        currentNote = NoteEntity(
          // first time , brand new note ->id,uid temporary empty ''
          // NoteRDS firestore will asign id
          id: '',
          userId: userAuthId,
          title: currentTitle,
          content: currentContent,
          createdAt: DateTime.now(),
          isImportant: false,
        );
        await saveNote(currentNote!, userAuthId);
      } else {
        currentNote = currentNote!.copyWith(
          title: currentTitle,
          content: currentContent,
        );
        // _noteController.updateNote(_currentNote!);
        // saveNotes , single Upsert Method for RDS FireStore
        await saveNote(currentNote!, userAuthId);
      }
    } catch (e) {
      debugPrint(
        'Error in Note ctr > saveCurrentNote ======> ${e.toString()} ',
      );
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // handle Back buttons
  // NEW CHANGE: Moved `_handleBackButton` logic completely into NoteController
  Future<void> handleBackButton() async {
    // Explicit save note UI/UX ,so we dont auto save on back.
    // changes discarded after back.
    /* final String currentTitle = _titleController.text;
    final String currentContent = _contentController.text;
    if (currentTitle.trim().isEmpty && currentContent.trim().isEmpty && _currentNote != null) {
      //await since noteController's deleteNote uses await.it takes time
      await _noteController.deleteNote(_currentNote!.id);
    } */
    debugPrint(
      "Moving Back .Local Data Storage List has ${noteList.length.toString()} items. . . . . . = = = = List -->${noteList} .. .. Cureent Note --> ${currentNote?.title.toString()}",
    );
    // discard local selected and previous cloud media removes
    // keep previous cloud media
    clearMediaPreview();
    currentNote = null; // Clear the local variable so it knows the note is gone
    Get.back();
  }

  //UI SignOut Action:
  Future<void> noteViewSignOut() async {
    try {
      //start Loading spinner
      //dialog -> like nav to new screen
      //if want to close -> get Back to previous screen
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
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

  //UI Action 2: Create
  //step 0 :add userAuthParam for upmedUC
  Future<void> saveNote(NoteEntity note, String userAuthId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      //# media attacment feat
      //# user action 2 : finally saving the note
      if (cloudPathsToDelete.isNotEmpty) {
        //delete the previous Cloud Paths to delete:
        await _deleteMediaUsecase(publicUrls: cloudPathsToDelete);
      }
      //1.emp list for cloud urls
      List<String> newCloudUrls = [];
      //2.get cloud urls if user had selected media
      //to decide type (.contains '.mp4')in step 3
      if (selectedLocalMediaPaths.isNotEmpty) {
        newCloudUrls = await _uploadMultipleMediaUsecase(
          mediaLocalPaths: selectedLocalMediaPaths,
          userAuthId: userAuthId,
        );
      }
      //3.create med att (nested entities)
      List<MediaAttachmentNestedEntity> newAttachments = newCloudUrls.map((
        url,
      ) {
        final isVideo =
            url.toLowerCase().contains('.mp4') ||
            url.toLowerCase().contains('.mov');
        return MediaAttachmentNestedEntity(
          mediaType: isVideo ? NoteMediaType.video : NoteMediaType.image,
          mediaLink: url,
        );
      }).toList();
      //4. add att to att list in already existing entity if any
      //~~1.4 join the edited new cloud media attachments, not old list
      final allAttachments = [...currentCloudMedia, ...newAttachments];
      debugPrint(
        'NoteCtr>saveNote>now ${allAttachments.length} Allattachments are being injected in Note entity ',
      );

      //prepare new enity all attachments to finally send to addNoteUC
      final NoteEntity noteToSave = note.copyWith(
        mediaAttachments: allAttachments,
      );
      debugPrint(
        'NoteCtr>saveNote>New note entity made with allAttList:$noteToSave',
      );

      //just direct() bcz of call in UC ---FOR RDS FireStore
      await _saveNoteUsecase(noteToSave);
      debugPrint(
        'noteCtrl -> addNote -> note title is -> ${noteToSave.title} ,.,.,.number of attachments=>${noteToSave.mediaAttachments.length}',
      );
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

  //Meadia Attach sub feat
  //UI action [1]:pickMed
  Future<void> pickLocalMedia({
    required NoteMediaSource source,
    required NoteMediaType type,
  }) async {
    try {
      final List<String> pickedPaths = await _pickMediaUsecase.call(
        source: source,
        type: type,
      );
      //only add if user didn't discards
      if (pickedPaths.isNotEmpty) selectedLocalMediaPaths.addAll(pickedPaths);
    } catch (e) {
      debugPrint("NoteController > pickMedia : ERROR ==> $e");
      errorMessage.value = "Failed to pick images: ${e.toString()}";
    }
  }

  //~~~1.3 unified remove (remove curCloud or fresh local paths)
  //index will come from ListVB of note preview
  void removeMedia({required int index}) {
    int cloudMediaListLength = currentCloudMedia.length;
    if (index < cloudMediaListLength) {
      final String cloudLink = currentCloudMedia[index].mediaLink;
      cloudPathsToDelete.add(cloudLink);
      currentCloudMedia.removeAt(index);
    } else {
      int localMediaIndex = index - cloudMediaListLength;
      selectedLocalMediaPaths.removeAt(localMediaIndex);
    }
  }

  //for discarding changes
  //befor Get.back of handle back
  void clearMediaPreview() {
    selectedLocalMediaPaths.clear();
  }
}
