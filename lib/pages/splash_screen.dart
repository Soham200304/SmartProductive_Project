import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartproductive_app/pages/auth_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 10), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthPage()
          )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF90E0EF), // Frosty blue
              Color(0xFF00B4D8), // Light aqua blue            ],
              Color(0xFF0096C7), // Blue lagoon
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Center(
            //child: Image.asset('lib/images/sp.png'),
          ),
        ),
      ),
    );
  }
}
