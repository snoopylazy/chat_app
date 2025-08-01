import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/components/my_button.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final void Function()? onTap;
  const RegisterScreen({super.key, required this.onTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Register
  void register(BuildContext context) async {
    final auth = AuthService();

    if (_passwordController.text != _confirmPasswordController.text) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Passwords do not match"),
        ),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Missing Information"),
          content: Text("Please fill out all fields."),
        ),
      );
      return;
    }

    try {
      await auth.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Registration Error"),
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                "Let's create an account for you!",
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
              MyTextfield(
                hintText: "Confirm Password",
                obscureText: true,
                controller: _confirmPasswordController,
              ),
              const SizedBox(height: 10.0),
              MyButton(
                text: "Register",
                onTap: () => register(context),
              ),
              const SizedBox(height: 25.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 4.0),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Login now",
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
