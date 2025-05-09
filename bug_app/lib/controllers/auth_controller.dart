import 'dart:convert';

import 'package:bug_app/models/user.dart';
import 'package:bug_app/providers/auth_provider.dart';
import 'package:bug_app/services/http_services.dart';
import 'package:bug_app/utils/constants.dart';
import 'package:bug_app/view/auth/login_screen.dart';
import 'package:bug_app/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final providerContainer = ProviderContainer();

class AuthController {
  Future<bool> signUpUser({
    required BuildContext context,
    required String name,
    required String email,
    required String phone,
    required String role,
    required String password,
  }) async {
    try {
      // Create user model
      User user = User(
        id: '',
        name: name,
        email: email,
        phone: phone,
        role: role,
        password: password,
        token: '',
      );

      // Convert user to JSON
      Map<String, dynamic> requestBody = user.toMap();

      http.Response response = await http.post(
        Uri.parse('$uri/api/auth/signup'), // ✅ FIXED: Corrected API endpoint
        body: jsonEncode(requestBody),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );

      bool success = false; // Track success status

      if (context.mounted) {
        httpResponse(
          response: response,
          context: context,
          onSuccess: () {
            success = true; // ✅ Mark success
            showSnackBar(context, 'Account created! Please log in.');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          },
        );
      }

      return success; // ✅ Return success status
    } catch (e) {
      showSnackBar(context, e.toString());
      return false; // ✅ Return false on error
    }
  }

//log in user
  Future<void> loginUser({
    required context,
    required String email,
    required String password,
    required WidgetRef ref,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse("$uri/api/auth/login"),
        body: jsonEncode(
            {"email": email, "password": password}), // Create a map here
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );

      httpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          //   //Access sharedPreferences for token and user data storage
          //   SharedPreferences preferences =
          //       await SharedPreferences.getInstance();

          //   //Extract the authentication token from the response body
          //   String token = jsonDecode(response.body)['token'];

          //   //STORE the authentication token securely in sharedPreferences

          //   preferences.setString('auth_token', token);

          //   //Encode the user data recived from the backend as json
          //   final userJson = jsonEncode(jsonDecode(response.body)['user']);

          //   //update the application state with the user data using Riverpod
          //   // ref.read(authProvider.notifier).setUser(userJson);
          //   providerContainer.read(authProvider.notifier).setUser(userJson);

          //   //store the data in sharePreference  for future use

          //   await preferences.setString('user', userJson);
          //   if (context.mounted) {
          //     Navigator.pushAndRemoveUntil(
          //       context,
          //       MaterialPageRoute(builder: (context) => HomeScreen()),
          //       (route) => false,
          //     );
          //     showSnackBar(context, 'Logged in');
          //   }
          // });
          final token = jsonDecode(response.body)['token'];
          final userMap = jsonDecode(response.body)['user'];

          // Attach token to userMap before converting to JSON
          userMap['token'] = token;

          final userJson = jsonEncode(userMap);

          // ✅ This will now update state and save to SharedPreferences
          // providerContainer.read(authProvider.notifier).setUser(userJson);
          ref.read(authProvider.notifier).setUser(userJson);

          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
            );
            showSnackBar(context, 'Logged in');
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

// sign up with invite
  Future<bool> signUpSeller({
    required BuildContext context,
    required String email,
    required String invitationCode,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse("$uri/api/auth/login-invite"),
        body: jsonEncode({
          "email": email,
          "invitationCode": invitationCode,
        }),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );

      bool success = false;

      if (context.mounted) {
        httpResponse(
          response: response,
          context: context,
          onSuccess: () {
            showSnackBar(context, "Seller signed up successfully!");
            success = true; // Update success status
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (_) => SetPasswordScreen(email: email)),
            // );
          },
        );
      }

      return success; // Return success status
    } catch (e) {
      showSnackBar(context, e.toString());
      return false; // Return false on error
    }
  }

// set passwor for seller
  Future<bool> setSellerPassword({
    required BuildContext context,
    required String email,
    required String password,
    required WidgetRef ref,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse("$uri/api/auth/set-password"),
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );

      bool success = false;

      if (context.mounted) {
        httpResponse(
          response: response,
          context: context,
          onSuccess: () {
            showSnackBar(context, "Password set successfully! Please log in.");
            success = true; // Set success to true inside onSuccess
          },
        );
      }

      return success; // Return success after processing
    } catch (e) {
      showSnackBar(context, e.toString());
      return false; // Return false if an error occurs
    }
  }

  //Signout

  Future<void> signOutUser(
      {required BuildContext context, required WidgetRef ref}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      //clear the token and user from SharedPreferenace
      await preferences.remove('auth_token');
      await preferences.remove('user');
      //clear the user state
      ref.read(authProvider.notifier).signOut();

      //navigate the user back to the login screen
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
          return const LoginScreen();
        }), (route) => false);

        showSnackBar(context, 'signout successfully');
      }
    } catch (e) {
      showSnackBar(context, "error signing out");
    }
  }

//
}
