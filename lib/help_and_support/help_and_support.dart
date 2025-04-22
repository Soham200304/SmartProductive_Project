import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpAndSupport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help & Support",
            style: GoogleFonts.alike(
                fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF4FC3F7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          color: Color(0xFFFFF9F2),
          child: Card(
            color: Colors.amber.shade50,
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.aboreto(color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Need help?\n\n",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
                    ),
                    TextSpan(
                      text:
                      "• Check the FAQs\n"
                          "• Make sure you're logged in properly\n"
                          "• Ensure your internet is working for data sync\n"
                          "• For any issues, contact us through email or app feedback.",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}