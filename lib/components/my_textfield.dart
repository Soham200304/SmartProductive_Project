import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextfield  extends StatelessWidget{
  final controller;
  final String hintText;
  final bool obscureText;
  final Icon? prefixIcon;
  final keyboardType;
  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.prefixIcon,
    required this.keyboardType
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        cursorColor: Colors.blue[400],
        style: GoogleFonts.alice(),
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.black54),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Color(0xFF4FC3F7)),
          ),
          fillColor: Color(0xFFFFF9F2),
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Color(0xFF37474F)),
        ),
      ),
    );
  }
}