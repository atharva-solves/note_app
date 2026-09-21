import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/features/note_app/presentation/controllers/note_controller.dart';
import 'package:note_app/features/note_app/presentation/widgets/attachment_bottom_sheet.dart';
import 'package:note_app/features/note_app/presentation/widgets/media_preview_list.dart';
// Import the separated widget files here
// import 'attachment_bottom_sheet.dart'; 
// import 'media_preview_list.dart'; 

// NEW CHANGE: Extending GetView<NoteController> automatically gives access to 'controller'
class EditNoteView extends GetView<NoteController> {
  const EditNoteView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disables default system navigation
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await controller.handleBackButton(); // Force our custom discard/save checks to run
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
            onPressed: controller.handleBackButton, // Runs validation check when clicking app bar arrow
          ),
          actions: [
            // Explicit Save Button
            Obx(() {
              final bool saving = controller.isLoading.value;
              return saving
                  ? const CircularProgressIndicator()
                  : IconButton(
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
                              await controller.saveCurrentNote();
                              controller.handleBackButton();
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
                // Calls the separated bottom sheet widget
                onPressed: () => Get.bottomSheet(const AttachmentBottomSheet()),
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
                // Modular horizontal media preview list
                const MediaPreviewList(),
                const SizedBox(height: 16),
                // TITLE INPUT
                TextField(
                  controller: controller.titleController,
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
                TextField(
                  controller: controller.contentController,
                  maxLines: null, // Allows the text field to grow infinitely downwards
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