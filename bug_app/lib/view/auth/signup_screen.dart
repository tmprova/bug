import 'package:bug_app/controllers/auth_controller.dart';
import 'package:bug_app/services/http_services.dart';
import 'package:bug_app/view/auth/login_screen.dart';
import 'package:bug_app/view/auth/set_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _invitationCodeController =
      TextEditingController();

  final AuthController _authController = AuthController();
  bool isLoading = false;
  String selectedRole = "seller"; // Default role

  signUp() async {
    setState(() {
      isLoading = true;
    });

    bool success = false;

    if (selectedRole == "seller") {
      // Planeteer Signup using /auth/signup-user
      if (_nameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _phoneController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        showSnackBar(context, 'Please fill in all fields.');
        setState(() => isLoading = false);
        return;
      }

      success = await _authController.signUpUser(
        context: context,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        role: selectedRole,
      );
    } else {
      // Buyer Signup using /auth/login-invite
      if (_emailController.text.isEmpty ||
          _invitationCodeController.text.isEmpty) {
        showSnackBar(
            context, 'Email and Invitation Code are required for Sellers.');
        setState(() => isLoading = false);
        return;
      }

      success = await _authController.signUpSeller(
        context: context,
        email: _emailController.text,
        invitationCode: _invitationCodeController.text,
      );
    }

    if (success) {
      if (!mounted)
        return; // Ensure the widget is still in the tree before using context

      if (selectedRole == "seller") {
        // Responder goes to Set Password Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SetPasswordScreen(email: _emailController.text),
          ),
        );
      } else {
        // buyer goes to Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: "Select Role",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.green, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.green.shade300, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.green.shade50,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
                items: const [
                  DropdownMenuItem(
                    value: "buyer",
                    child: Text("🌍 buyer", style: TextStyle(fontSize: 16)),
                  ),
                  DropdownMenuItem(
                    value: "seller",
                    child: Text("🚀 seller", style: TextStyle(fontSize: 16)),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Email field (ALWAYS VISIBLE)
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.green.shade50,
                ),
              ),
              const SizedBox(height: 12),

              if (selectedRole == "seller") ...[
                // Invitation Code field (Only for seller)
                TextField(
                  controller: _invitationCodeController,
                  decoration: InputDecoration(
                    labelText: 'Invitation Code',
                    prefixIcon: const Icon(Icons.vpn_key, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.green.shade50,
                  ),
                ),
              ],

              if (selectedRole == "buyer") ...[
                // Fields only for buyer
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: const Icon(Icons.person, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.green.shade50,
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: const Icon(Icons.phone, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.green.shade50,
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock, color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.green.shade50,
                  ),
                ),
              ],
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(vertical: 22, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
