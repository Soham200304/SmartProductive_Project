import 'package:flutter/material.dart';
import 'package:smartproductive_app/home_page/home_page.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  bool _isSecondPage = true;

  void _togglePage(bool value) {
    setState(() {
      _isSecondPage = value;
    });
    if (!value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF90E0EF),
        actions: [
          // Switch(
          //   value: _isSecondPage,
          //   onChanged: _togglePage,
          // ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD0FFD0), // Gentle Minty Green
              Color(0xFF90EE90), // Soft Light Green
            ],
          ),
        ),
        child: Center(child: Text('Hello')),
      ),
    );
  }
}
