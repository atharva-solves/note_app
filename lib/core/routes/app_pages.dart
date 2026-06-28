import 'package:get/get.dart';
import 'package:note_app/core/routes/app_routes.dart';
import 'package:note_app/features/note_app/presentation/bindings/note_binding.dart';
import 'package:note_app/features/note_app/presentation/views/notes_view.dart';
import 'package:note_app/features/note_app/presentation/views/unified_add_edit_note_view.dart';

abstract class AppPages {
  //priv constr
  AppPages._();

  //first screen of app
  static const String initial = AppRoutes.home;

  static final List<GetPage> pages = [
    GetPage(
      name: initial,
      //const bcz view doesn req var in construct.its const and known before app runs.
      page: () => const NotesView(),
      binding: NoteBinding(),
    ),
    GetPage(
      name: AppRoutes.addEditNote,
      page: () => const UnifiedAddEditNoteView(),
    ),
  ];
}
