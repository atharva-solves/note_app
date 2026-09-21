import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/features/note_app/domain/enums/media_attachment_enums.dart';
import 'package:note_app/features/note_app/presentation/controllers/note_controller.dart';

// NEW CHANGE: Extending GetView<NoteController> eliminates Get.find()
class AttachmentBottomSheet extends GetView<NoteController> {
  const AttachmentBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              controller.pickLocalMedia(
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
              controller.pickLocalMedia(
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
              controller.pickLocalMedia(
                source: NoteMediaSource.gallery,
                type: NoteMediaType.image, // Any maps to images/videos in gallery
              );
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}