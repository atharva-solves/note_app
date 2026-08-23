import 'dart:async';
import 'package:get/state_manager.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startSplashTimer();
  }

  void _startSplashTimer() {
    Timer(const Duration(seconds: 4), () {});
  }
}
