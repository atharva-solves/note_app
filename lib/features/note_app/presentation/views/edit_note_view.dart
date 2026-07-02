import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:note_app/features/note_app/data/models/note_model.dart';
import 'package:note_app/features/note_app/presentation/controllers/note_controller.dart';
import 'package:uuid/uuid.dart';

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
  NoteModel? _currentNote = Get.arguments as NoteModel?;
  final NoteController _noteController = Get.find<NoteController>();
  //Birth
  @override
  void initState() {
    super.initState();

    //fill if note exist else empty str
    _titleController = TextEditingController(
      text: _currentNote != null ? _currentNote!.title : '',
    );
    _contentController = TextEditingController(
      text: _currentNote != null ? _currentNote!.content : '',
    );

    _titleController.addListener(_autoSaveNote);
    _contentController.addListener(_autoSaveNote);
  }

  //Death ! clear ram when view is LEFT
  @override
  void dispose() {
    super.dispose();

    //auto deletes listner
    _titleController.dispose();
    _contentController.dispose();
  }

  //runs on every change
  _autoSaveNote() {
    //extract String from ctrl
    final String currentTitle = _titleController.text;
    final String currentContent = _contentController.text;

    //Gaurd Clause.gaurd us from running actions if the note is EMPTY.
    //Soc 1.validation 1.Actions
    //let Back buttons handle the deleting action
    if (currentTitle.trim().isEmpty && currentContent.trim().isEmpty) {
      return;
    }

    //Soc .Actions A.If new note,ADD(create) else B.Update
    if (_currentNote == null) {
      _currentNote = NoteModel(
        id: const Uuid().v4(),
        title: currentTitle,
        content: currentContent,
        createdAt: DateTime.now().toIso8601String(),
        isImportant: false,
      );

      _noteController.addNote(_currentNote!);
    } else {
      _currentNote = _currentNote!.copyWith(
        title: currentTitle,
        content: currentContent,
      );
      _noteController.updateNote(_currentNote!);
    }
  }

  //
  //handle Back buttons
  Future<void> _handleBackButton() async {
    final String currentTitle = _titleController.text;
    final String currentContent = _contentController.text;

    if (currentTitle.trim().isEmpty &&
        currentContent.trim().isEmpty &&
        _currentNote != null) {
      //await since noteController's deleteNote uses await.it takes time
      await _noteController.deleteNote(_currentNote!.id);
    }

    print(
      "Back Button is Pressed .Local Data Storage List has ${_noteController.noteList.length.toString()} items.   . . . . . = = = = List --> ${_noteController.noteList} .. .. Cureent Note --> ${_currentNote?.title.toString()}",
    );

    _currentNote = null; // Clear the local variable so it knows the note is gone
    Get.back();
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
        ),

        // 3. Simple Text Input Fields
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
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
                  border: InputBorder.none, // Removes standard ugly underlines
                ),
              ),
              const SizedBox(height: 8),

              // CONTENT INPUT
              Expanded(
                child: TextField(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
