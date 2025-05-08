import 'package:bug_app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  ProfileScreen({super.key});
  final AuthController authController = AuthController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Use this button to Logout",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // reportController.testBackendConnection();
                authController.signOutUser(context: context, ref: ref);
              },
              child: const Text("Log out"),
            ),
          ],
        ),
      ),
    );
  }
}
