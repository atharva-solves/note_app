import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/core/routes/app_routes.dart';
import 'package:note_app/features/note_app/presentation/widgets/note_card.dart';
import '../controllers/note_controller.dart';

// By extending GetView<NoteController>, GetX automatically finds our brain in memory
class NotesView extends GetView<NoteController> {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notes',
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.w800, // Heavy weight for a modern look
            letterSpacing: -1.2,
          ),
        ),
      ),

      // Obx is our "Cashier", constantly watching the noteList
      body: Obx(() {
        // 1. EMPTY STATE
        if (controller.noteList.isEmpty) {
          return const Center(
            child: Text(
              'No notes yet.\nclick "+" to add note.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          );
        }

        // 2. GRID STATE (This will show your Dummy Data!)
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: controller.noteList.length,
          itemBuilder: (context, index) {
            final note = controller.noteList[index];

            return NoteCardWidget(note: note, controller: controller);
          },
        );
      }),

      // FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          // Passing 'null' tells the next screen: "This is a brand new note!"
          Get.toNamed(AppRoutes.editNote, arguments: null);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
