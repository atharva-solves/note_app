import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:note_app/core/bindings/initial_binding.dart';
import 'package:note_app/core/routes/app_pages.dart';

void main() async {
  //since await before runApp,WFB.eI() ==> connect flutter framework(Dart code-wid ,ctr..)and Flutter Engine(C++: draws actual the pixel)
  WidgetsFlutterBinding.ensureInitialized();

  //start GetStor engine in phones hardware
  await GetStorage.init();
  //  Flip the Main Power Switch to turn on the Firebase Kitchen!
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Notes app with CCA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      //first screen as app opens
      initialRoute: AppPages.initial,

      //point Routing
      getPages: AppPages.pages,

      //core checklist/binding .born as soon as app starts and lives till app life cycle
      initialBinding: InitialBinding(),
    );
  }
}
