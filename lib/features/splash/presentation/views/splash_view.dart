import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:note_app/core/constants/app_assets/image_assets_path.dart';
import 'package:note_app/features/splash/presentation/controllers/splash_controller.dart';

class SplashView extends GetView<SplashController>{
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      body: Image.asset(
        ImageAssetsPath.splashImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

}