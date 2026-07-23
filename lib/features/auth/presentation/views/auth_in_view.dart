import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/features/auth/presentation/controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  // Hardcoded dummy credentials for testing
  static const String _dummyEmail = 'testuser@gmail.com';
  static const String _dummyPassword = 'password123';

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
                        ? 'Active Session: ${user.email}'
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

              // 3. Test Sign Out Use Case
              ElevatedButton(
                onPressed: () {
                  debugPrint('[UI Test] Triggering SignOut UseCase');
                  controller.signOut();
                },
                child: const Text('3. Test Sign Out'),
              ),
              const SizedBox(height: 12),

              // 4. Test Delete Account Use Case
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  debugPrint('[UI Test] Triggering DeleteAccount UseCase');
                  controller.deleteAccount();
                },
                child: const Text('4. Test Delete Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
