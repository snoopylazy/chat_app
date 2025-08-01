import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const MyTextfield({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        obscureText: obscureText, // Use the obscureText parameter
        controller: controller,
        focusNode: focusNode,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}