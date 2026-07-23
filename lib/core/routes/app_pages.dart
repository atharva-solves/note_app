import 'package:get/get.dart';
import 'package:note_app/core/routes/app_routes.dart';
import 'package:note_app/features/auth/presentation/views/log_in_view.dart';
import 'package:note_app/features/auth/presentation/views/splash_view.dart';
import 'package:note_app/features/note_app/presentation/bindings/note_binding.dart';
import 'package:note_app/features/note_app/presentation/views/notes_view.dart';
import 'package:note_app/features/note_app/presentation/views/edit_note_view.dart';

abstract class AppPages {
  //priv constr
  AppPages._();

  

  static final List<GetPage> pages = [
    //feature specific ctr =>bind with Get page
    //Global ctr (initBind) => Not here. bcz in main.
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(name: AppRoutes.login, page: () => const LoginView()),
    GetPage(
      name: AppRoutes.home,
      //const bcz view doesn req var in construct.its const and known before app runs.
      page: () => const NotesView(),
      binding: NoteBinding(),
    ),
    GetPage(name: AppRoutes.editNote, page: () => const EditditNoteView()),
  ];
}
