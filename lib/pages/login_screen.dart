import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/components/my_button.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final void Function()? onTap;
  const LoginScreen({super.key, required this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Login method
  void login(BuildContext context) async {
    final authService = AuthService();

    // Simple validation
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Missing Information"),
          content: Text("Please enter both email and password."),
        ),
      );
      return;
    }

    try {
      await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Login Error"),
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 40.0),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 50.0),
              Text(
                "Welcome back, you've been missed",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 25.0),
              MyTextfield(
                hintText: "Email",
                obscureText: false,
                controller: _emailController,
              ),
              const SizedBox(height: 10.0),
              MyTextfield(
                hintText: "Password",
                obscureText: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 10.0),
              MyButton(
                text: "Login",
                onTap: () => login(context),
              ),
              const SizedBox(height: 25.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not a member?",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 4.0),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Register now",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
