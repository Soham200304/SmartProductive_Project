import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class MyButton extends StatelessWidget {

  final Function()? onTap;
  final String text;
  const MyButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 310,
        height: 75,
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4FDB90),
              Color(0xFF4FDB60),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.alice(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
