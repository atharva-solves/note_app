import 'package:get/get.dart';
import 'package:note_app/core/routes/app_routes.dart';
import 'package:note_app/features/note_app/presentation/bindings/note_binding.dart';

abstract class AppPages {
  //priv constr
  AppPages._();

  //first screen of app
  static const String initial = AppRoutes.home;

  static final List<GetPage> pages = [
    GetPage(
      name: initial,
      page: () => const NoteView(), //will build in step 5E
      binding: NoteBinding(),
    ),
  ];
}
