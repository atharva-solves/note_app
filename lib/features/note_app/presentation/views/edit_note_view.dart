import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:note_app/features/note_app/data/models/note_model.dart';

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
  // it will transform into a real note the second the user types a letter!
   NoteModel? _currentNote = Get.arguments as NoteModel?;

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
  }

  //Death ! clear ram when view is LEFT
  @override
  void dispose() {
    super.dispose();

    _titleController.dispose();
    _contentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Add/Edit View coming soon...')));
  }
}
