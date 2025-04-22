import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialMedia extends StatelessWidget {
  const SocialMedia({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Social Media",
            style: GoogleFonts.alike(
                fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: const Color(0xFF4FC3F7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          color: Color(0xFFFFF9F2),
          child: Card(
            color: Colors.green.shade50,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.aboreto(fontSize: 15, color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Connect with us on:\n\n",
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                      "📷 Instagram: @smartproductive_app\n"
                      "\n"
                      "🐤 X: @SmartProductive\n"
                      "\n"
                      "📘 Facebook: SmartProductiveApp\n"
                      "\n"
                      "▶️ YouTube: SmartProductive Official\n"
                      "\n"
                      "📧 Email: support@smartproductive.com"
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
