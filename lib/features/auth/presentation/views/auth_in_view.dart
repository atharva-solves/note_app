import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/features/auth/presentation/controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  // Hardcoded dummy credentials for testing
  static const String _dummyEmail = 'testuser@gmail.com';
  static const String _dummyPassword = 'password123';

  // Hardcoded dummy phone number (Ensure this matches your Firebase Test numbers)
  static const String _dummyPhone = '+919999999999';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Auth Backend Test'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          // 1. ADDED: SingleChildScrollView to prevent pixel overflow on small screens
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 0. Reactive User State Status Display
                Obx(() {
                  final user = controller.currentUser.value;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      user != null
                          // Safely checking for email, fallback to a general active message
                          ? 'Active Session: ${user.email ?? "Phone Auth User"}'
                          : 'Active Session: None',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }),
                const SizedBox(height: 30),

                // 1. Test Sign Up Use Case
                ElevatedButton(
                  onPressed: () {
                    debugPrint('[UI Test] Triggering SignUp UseCase');
                    controller.signUp(
                      email: _dummyEmail,
                      password: _dummyPassword,
                    );
                  },
                  child: const Text('1. Test Sign Up'),
                ),
                const SizedBox(height: 12),

                // 2. Test Sign In Use Case
                ElevatedButton(
                  onPressed: () {
                    debugPrint('[UI Test] Triggering SignIn UseCase');
                    controller.signIn(
                      email: _dummyEmail,
                      password: _dummyPassword,
                    );
                  },
                  child: const Text('2. Test Sign In'),
                ),
                const SizedBox(height: 12),

                // 3. Test Google Sign in Use Case
                ElevatedButton(
                  onPressed: () {
                    debugPrint('[UI Test] Triggering Google Sign in UseCase');
                    controller.googleSignIn();
                  },
                  child: const Text('3. Test Google Sign in'),
                ),
                const SizedBox(height: 12),

                // 4. Test Sign Out Use Case
                ElevatedButton(
                  onPressed: () {
                    debugPrint('[UI Test] Triggering SignOut UseCase');
                    controller.signOut();
                  },
                  child: const Text(
                    '4. Test Sign Out',
                  ), // Fixed the number sequence text
                ),
                const SizedBox(height: 12),

                // 5. Test Delete Account Use Case
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    debugPrint('[UI Test] Triggering DeleteAccount UseCase');
                    controller.deleteAccount();
                  },
                  child: const Text(
                    '5. Test Delete Account',
                  ), // Fixed the number sequence text
                ),
                const SizedBox(height: 30),

                const Divider(thickness: 2),
                const SizedBox(height: 30),

                // 6. ADDED: Test Phone Auth Use Case
                Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            debugPrint('[UI Test] Triggering SendOtp UseCase');
                            controller.sendOtp(_dummyPhone);
                          },
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('6. Test Phone Auth ($_dummyPhone)'),
                  ),
                ),

                Obx(
                  () => TextButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            debugPrint("UI: Guest Login Button Pressed");
                            controller.signInAnonymously();
                          },
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Continue as Guest",
                            style: TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
