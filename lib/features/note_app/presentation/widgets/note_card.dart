import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:note_app/core/routes/app_routes.dart';
import 'package:note_app/features/note_app/data/models/note_model.dart';
import 'package:note_app/features/note_app/presentation/controllers/note_controller.dart';

class NoteCardWidget extends StatelessWidget {
  final NoteModel note;
  final NoteController controller;
  const NoteCardWidget({
    super.key,
    required this.note,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Clicking an existing note passes that specific note to the editor
        Get.toNamed(AppRoutes.editNote, arguments: note);
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
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
    ;
  }
}
