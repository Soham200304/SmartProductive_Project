import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us',
            style: GoogleFonts.alike(
                fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Color(0xFF4FC3F7),
      ),
      body: Container(
        color: Color(0xFFFFF9F2),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard(
                title: "Description",
                color: Color(0xFFFFCDD2),
                content:
                "SmartProductive is a productivity app designed to help users manage tasks efficiently, "
                    "stay focused using a gamified timer, earn reward coins, analyze performance via dynamic reports, "
                    "and receive AI-powered activity suggestions to stay motivated.",
              ),
              const SizedBox(height: 16),
              _buildCard(
                title: "Objective",
                color: Color(0xFFCDFFF9),
                content:
                "The main objective of this app is to enhance productivity by combining task management, "
                    "time tracking, and motivational tools like rewards and progress tracking. "
                    "It encourages users to develop consistent focus habits and better understand their work patterns through insights "
                    "and AI suggestions.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required String content, required Color color}) {
    return Card(
      color: color,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.aboreto(
                    fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            Text(content, style: GoogleFonts.aboreto(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
