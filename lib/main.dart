import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:note_app/core/routes/app_pages.dart';
import 'package:note_app/core/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //start GetStor engine in phones hardware
  GetStorage.init();

  //since Core, put Instance before app Created .
  Get.put(StorageService());

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
    );
  }
}
