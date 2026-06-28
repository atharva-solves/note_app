import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/note_controller.dart';

// By extending GetView<NoteController>, GetX automatically finds our brain in memory
class NotesView extends GetView<NoteController> {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gen-Z Minimalist flat white background
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

            return GestureDetector(
              onTap: () {
                // Clicking an existing note passes that specific note to the editor
                Get.toNamed('/edit-note', arguments: note);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ), // Clean, subtle border
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE (With fallback for empty titles)
                    Text(
                      note.title.trim().isNotEmpty ? note.title : 'Untitled',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // CONTENT
                    Expanded(
                      child: Text(
                        note.content,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // BOTTOM ROW: IMPORTANT & DELETE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Important Toggle (Star)
                        GestureDetector(
                          onTap: () => controller.toggleImportant(note.id),
                          child: Icon(
                            note.isImportant
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: note.isImportant
                                ? Colors.black
                                : Colors.grey.shade400,
                            size: 24,
                          ),
                        ),
                        // Delete Button
                        GestureDetector(
                          onTap: () => controller.deleteNote(note.id),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.grey.shade400,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
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
          Get.toNamed('/edit-note', arguments: null);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
