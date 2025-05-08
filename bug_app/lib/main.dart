import 'dart:convert';

import 'package:bug_app/providers/auth_provider.dart';
import 'package:bug_app/services/location_service.dart';
import 'package:bug_app/view/auth/login_screen.dart';
import 'package:bug_app/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // Future<void> checkTokenAndSetUser(WidgetRef ref) async {
  //   // Obtain an instance of SharedPreferences
  //   SharedPreferences preferences = await SharedPreferences.getInstance();

  //   // Retrieve the authentication token and user data stored locally
  //   String? token = preferences.getString('auth_token');
  //   String? userJson = preferences.getString('user');
  //   print("🔍 Retrieved userJson from SharedPreferences: $userJson");

  //   // If both the token and data are available, update the user state
  //   if (token != null && userJson != null) {
  //     ref.read(authProvider.notifier).setUser(userJson);
  //   } else {
  //     ref.read(authProvider.notifier).signOut();
  //   }
  // }
  // Future<void> checkTokenAndSetUser(WidgetRef ref) async {
  //   print("🚀 Starting checkTokenAndSetUser");

  //   // Call loadUser from AuthProvider
  //   await ref.read(authProvider.notifier).loadUser();

  //   // Get the user after loading
  //   final user = ref.read(authProvider);

  //   if (user != null && user.token != null) {
  //     print("✅ User and token found. Optionally refresh the token here.");

  //     // 🔁 OPTIONAL: Add token refresh logic here if needed
  //     // bool tokenValid = await validateToken(user.token!);
  //     // if (!tokenValid) {
  //     //   ref.read(authProvider.notifier).signOut();
  //     // }
  //   } else {
  //     print("❌ No user or token found.");
  //     ref.read(authProvider.notifier).signOut();
  //   }
  // }

  // Future<Position?> getCurrentLocation() async {
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) return null;

  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.deniedForever) {
  //       return null;
  //     }
  //   }

  //   return await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  // }
  bool isTokenExpired(String token) {
    final payload = jsonDecode(
        utf8.decode(base64.decode(base64.normalize(token.split(".")[1]))));
    final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
    return DateTime.now().isAfter(expiry);
  }

  Future<void> verifyUserToken(WidgetRef ref) async {
    final user = ref.read(authProvider);
    if (user == null || user.token == null || isTokenExpired(user.token!)) {
      print("🔐 Invalid or expired token. Signing out.");
      ref.read(authProvider.notifier).signOut();
    } else {
      print("🔓 Token is valid. User is logged in.");
    }
  }

  Future<void> initializeLocation() async {
    Position? position = await getCurrentLocation();
    if (position != null) {
      print("User location: ${position.latitude}, ${position.longitude}");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Planet App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FutureBuilder(
        //   future: checkTokenAndSetUser(ref),
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return const Scaffold(
        //         body: Center(child: CircularProgressIndicator()),
        //       );
        //     }

        //     final user = ref.watch(authProvider);

        //     return user != null ? HomeScreen() : const LoginScreen();
        //   },
        // ),
        // onGenerateRoute: Routes.generateRoute,
        future: verifyUserToken(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = ref.watch(authProvider);
          // final isLoading = ref.watch(authLoadingProvider);

          // if (isLoading) {
          //   return const Center(child: CircularProgressIndicator());
          // }

          return user != null ? HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}
