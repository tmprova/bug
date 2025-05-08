import 'dart:convert';

import 'package:bug_app/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends StateNotifier<User?> {
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  AuthProvider() : super(null) {
    loadUser(); // ✅ Load user from local storage
  }
  // Getter method to extract the current user state
  User? get user => state;

  // Method to set the user state from a JSON string (login process)
  // void setUser(String userJson) {
  //   state =
  //       User.fromJson(userJson); // Parse JSON to User object and update state
  //   print("✅ User set: ${state?.id}");
  // }
  void setUser(String userJson) async {
    final user = User.fromJson(userJson);
    state = user;

    final prefs = await SharedPreferences.getInstance();

    // ✅ Save token from user object
    if (user.token != null) {
      await prefs.setString('auth_token', user.token!);
      print("✅ Saving token to prefs: ${user.token}");
    } else {
      print("❌ Token is null while saving!");
    }

    // ✅ Save full user JSON (including token)
    await prefs.setString('user', jsonEncode(user.toMap()));
    print("✅ User saved to prefs: ${user.id}");
  }

  // Method to clear the user state (sign out process)
  void signOut() {
    state = null; // Set the state to null when user signs out
  }

  Future<void> loadUser() async {
    _isLoading = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    String? token = prefs.getString('auth_token');

    print("🧠 Attempting to load user...");
    print("📦 Raw userJson: $userJson");
    print("🔑 Token from prefs: $token");
    state = state;
    if (userJson != null && token != null) {
      final userMap = jsonDecode(userJson);
      userMap['token'] = token;
      state = User.fromMap(userMap);
      _isLoading = false;
      print("✅ User restored with token: ${state?.token}");
    } else {
      state = null;
      print("🚫 No user or token found. Logging out.");
    }
  }

  // Future<void> loadUser() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? userJson = prefs.getString('user');
  //   String? token = prefs.getString('auth_token');
  //   print("User Token before restoring: $token");

  //   if (userJson != null) {
  //     final Map<String, dynamic> userMap = jsonDecode(userJson);
  //     userMap['token'] = token;
  //     state = User.fromMap(userMap);
  //     print("✅ User restored: ${state?.toJson()}");
  //   } else {
  //     state = null;
  //   }

  //   _isLoading = false;
  // }
}

// Define the provider that makes the Auth state available throughout the app
final authProvider = StateNotifierProvider<AuthProvider, User?>((ref) {
  return AuthProvider();
});

final authLoadingProvider = Provider<bool>((ref) {
  final auth = ref.watch(authProvider.notifier);
  return auth.isLoading;
});
