import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:note_app/features/note_app/domain/entity/note_entity.dart';
import 'package:note_app/features/note_app/domain/enums/media_attachment_enums.dart';
import 'package:note_app/features/note_app/presentation/controllers/note_controller.dart';
//firestore has functionality to generate ID (we'll use for note ID)
//no need of extra package
//import 'package:uuid/uuid.dart';

//stf :bcz using a UI widget(Txt F.) that req its mem manag (own life cycle)(init disp ctr)
class EditditNoteView extends StatefulWidget {
  const EditditNoteView({super.key});

  @override
  State<EditditNoteView> createState() => _EditditNoteViewState();
}

class _EditditNoteViewState extends State<EditditNoteView> {
  //late :only init when actually page/view is opened(init).
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  //arg receive
  //remove 'final' because if this starts as 'null',
  //due to (constantly listen and save business logic)
  // it will transform into a real note the second the user types a letter!
  NoteEntity? _currentNote = Get.arguments as NoteEntity?;
  final NoteController _noteController = Get.find<NoteController>();
  //Birth
  @override
  void initState() {
    super.initState();
    //checking wether previous media attachments are inserted
    debugPrint(
      '<><><><><> Edit Note View>onInit > previous attachments : ${_noteController.currentCloudMedia.length} <><><><><><><><><',
    );
    //fill if note exist else empty str
    _titleController = TextEditingController(
      text: _currentNote != null ? _currentNote!.title : '',
    );
    _contentController = TextEditingController(
      text: _currentNote != null ? _currentNote!.content : '',
    );

    //since firestore R/W limit ,Change business logic from auto save --> save button and back
    /* _titleController.addListener(_autoSaveNote);
    _contentController.addListener(_autoSaveNote); */
  }

  //Death ! clear ram when view is LEFT
  @override
  void dispose() {
    super.dispose();

    //auto deletes listner
    _titleController.dispose();
    _contentController.dispose();
  }

  //runs on every change for local DS Get Storage ,its fast and free
  //auto save -->save Notes for RDS FireStore, limited R/W access. takes time.
  Future<void> _saveNote() async{
    //extract String from ctrl
    final String currentTitle = _titleController.text;
    final String currentContent = _contentController.text;
    final String userAuthId = FirebaseAuth.instance.currentUser!.uid;

    //Gaurd Clause.gaurd us from running actions if the note is EMPTY.and
    //Soc 1.validation 1.Actions
    //let Back buttons handle the deleting action
    if (currentTitle.trim().isEmpty &&
        currentContent.trim().isEmpty &&
        _noteController.currentCloudMedia.isEmpty &&
        _noteController.selectedLocalMediaPaths.isEmpty) {
      return;
    }

    //Soc .Actions A.If new note,ADD(create) else B.Update
    if (_currentNote == null) {
      _currentNote = NoteEntity(
        //first time , brand new note ->id,uid temporary empty ''
        //NoteRDS firestore will asign id
        id: '',
        userId: userAuthId,
        title: currentTitle,
        content: currentContent,
        createdAt: DateTime.now(),
        isImportant: false,
      );

      _noteController.saveNote(_currentNote!, userAuthId);
    } else {
      _currentNote = _currentNote!.copyWith(
        title: currentTitle,
        content: currentContent,
      );
      //_noteController.updateNote(_currentNote!);

      //saveNotes , single Upsert Method for RDS FireStore
     await _noteController.saveNote(_currentNote!, userAuthId);
    }
  }

  //
  //handle Back buttons
  Future<void> _handleBackButton() async {
    //Explicit save note UI/UX ,so we dont auto save on back.
    //changes discarded after back.
    /* final String currentTitle = _titleController.text;
    final String currentContent = _contentController.text;

    if (currentTitle.trim().isEmpty &&
        currentContent.trim().isEmpty &&
        _currentNote != null) {
      //await since noteController's deleteNote uses await.it takes time
      await _noteController.deleteNote(_currentNote!.id);
    } */

    debugPrint(
      "Moving Back .Local Data Storage List has ${_noteController.noteList.length.toString()} items.   . . . . . = = = = List --> ${_noteController.noteList} .. .. Cureent Note --> ${_currentNote?.title.toString()}",
    );
    //discard local selected and previous cloud media removes
    //keep previous cloud media
    _noteController.clearMediaPreview();

    _currentNote =
        null; // Clear the local variable so it knows the note is gone
    Get.back();
  }

  // STEP 3: Minimalist Bottom Sheet Menu
  void _showAttachmentBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo'),
              onTap: () {
                _noteController.pickLocalMedia(
                  source: NoteMediaSource.camera,
                  type: NoteMediaType.image,
                );
                Get.back();
              },
            ),
            /* ListTile(
              leading: const Icon(Icons.videocam_rounded),
              title: const Text('Record Video'),
              onTap: () {
                _noteController.pickLocalMedia(
                  source: NoteMediaSource.camera,
                  type: NoteMediaType.video,
                );
                Get.back();
              },
            ), */
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose Images'),
              onTap: () {
                _noteController.pickLocalMedia(
                  source: NoteMediaSource.gallery,
                  type: NoteMediaType
                      .image, // Any maps to images/videos in gallery
                );
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disables default system navigation
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackButton(); // Force our custom discard/save checks to run
      },
      child: Scaffold(
        backgroundColor: Colors.white,

        // 2. Consistent Minimalist AppBar
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black,
              size: 22,
            ),
            onPressed:
                _handleBackButton, // Runs validation check when clicking app bar arrow
          ),
          actions: [
            // Explicit Save Button
            Obx(() {
              final bool saving = _noteController.isLoading.value;

              return saving?CircularProgressIndicator():IconButton(
                icon: Icon(
                  Icons.check_rounded,
                  // Changes color to grey if saving, otherwise black
                  color: saving ? Colors.grey : Colors.black,
                  size: 26,
                ),
                // Disables the button press while saving to prevent duplicate taps
                onPressed: saving
                    ? null
                    : () async {
                       await  _saveNote();
                        _handleBackButton();
                      },
              );
            }),
          ],
        ),
        // Minimalist Bottom Nav to hold the '+' icon
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          elevation: 0,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
                onPressed: () => _showAttachmentBottomSheet(context),
              ),
            ],
          ),
        ),

        // 3. Simple Text Input Fields
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // --- SIMPLIFIED PACKAGE-DRIVEN MEDIA LIST ---
                Obx(() {
                  final totalMedia =
                      _noteController.currentCloudMedia.length +
                      _noteController.selectedLocalMediaPaths.length;
                  if (totalMedia == 0) return const SizedBox.shrink();

                  return SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: totalMedia,
                      itemBuilder: (context, index) {
                        final cloudLen =
                            _noteController.currentCloudMedia.length;
                        final isCloud = index < cloudLen;
                        final path = isCloud
                            ? _noteController.currentCloudMedia[index].mediaLink
                            : _noteController.selectedLocalMediaPaths[index -
                                  cloudLen];

                        //dont bload UI widgets (decImg)
                        //calculate image provider first &
                        //simple provide image (cached if cloud and file if local)
                        final ImageProvider imageProvider = isCloud
                            ? CachedNetworkImageProvider(path) as ImageProvider
                            : FileImage(File(path));
                        debugPrint(
                          '<><><><><><> Media Preview LVB:current media(isCloud:$isCloud) path:$path <><><><><><>',
                        );
                        return GestureDetector(
                          onTap: () {
                            //no need to build detail image view
                            //easy_image_provider
                            showImageViewer(
                              context,
                              imageProvider,
                              swipeDismissible: true,
                              doubleTapZoomable: true,
                            );
                          },

                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                    
                                    _noteController.removeMedia(index: index);

                                }
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // TITLE INPUT
                TextField(
                  controller: _titleController,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                    border:
                        InputBorder.none, // Removes standard ugly underlines
                  ),
                ),
                const SizedBox(height: 8),

                // CONTENT INPUT
                TextField(
                  controller: _contentController,
                  maxLines:
                      null, // Allows the text field to grow infinitely downwards
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                    height: 1.6, // Cleaner paragraph line spacing
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Start typing...',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
