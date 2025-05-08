import 'package:flutter/material.dart';

Widget buildPasswordField(String label, TextEditingController controller,
    bool obscureText, VoidCallback toggleVisibility) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      suffixIcon: IconButton(
        icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: toggleVisibility,
      ),
    ),
  );
}
