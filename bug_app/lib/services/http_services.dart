import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void httpResponse({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,
  Function(String)? onLocationMissing, // Callback when location is missing
}) {
  try {
    final responseBody = json.decode(response.body);
    String message = responseBody is Map
        ? (responseBody['msg'] ??
            responseBody['error'] ??
            'Something went wrong')
        : 'Unexpected response';

    switch (response.statusCode) {
      case 200: // OK - Successful request
      case 201: // Created - Resource successfully created
        onSuccess();
        break;
      case 400:

      case 401: // Unauthorized
      case 403: // Forbidden
      case 500: // Internal Server Error
        showSnackBar(context, message);
        break;
      default:
        showSnackBar(context, 'Unexpected error: ${response.statusCode}');
        break;
    }
  } catch (e) {
    showSnackBar(context, 'Error processing response');
  }
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      margin: const EdgeInsets.all(15),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.grey,
      content: Text(message),
    ),
  );
}
