import 'package:flutter/material.dart';

class MyTextfield  extends StatelessWidget{
  final controller;
  final String hintText;
  final bool obscureText;
  final Icon? prefixIcon;
  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.prefixIcon
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey),
          ),
          fillColor: Colors.blue.shade100,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black45),
        ),
      ),
    );
  }
}