import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/features/note_app/presentation/controllers/note_controller.dart';

// NEW CHANGE: Extending GetView<NoteController> eliminates Get.find()
class MediaPreviewList extends GetView<NoteController> {
  const MediaPreviewList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalMedia = controller.currentCloudMedia.length +
          controller.selectedLocalMediaPaths.length;
      if (totalMedia == 0) return const SizedBox.shrink();

      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: totalMedia,
          itemBuilder: (context, index) {
            final cloudLen = controller.currentCloudMedia.length;
            final isCloud = index < cloudLen;
            final path = isCloud
                ? controller.currentCloudMedia[index].mediaLink
                : controller.selectedLocalMediaPaths[index - cloudLen];

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
                      controller.removeMedia(index: index);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}