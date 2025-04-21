import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smartproductive_app/components/my_button.dart';
import 'package:smartproductive_app/components/my_textfield.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Sign user in and link with Firestore
  void signUserIn() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: LoadingAnimationWidget.inkDrop(color: Colors.white, size: 50),
        );
      },
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Get the user ID
      String uid = userCredential.user!.uid;

      // Update last login timestamp in Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "last_login": Timestamp.now(),
      });

      // Close the loading animation
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.code);
    }
  }

  // Error message pop-up
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF90E0EF), // Frosty blue
          title: Text(
            message,
            style: const TextStyle(fontSize: 25),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF9F2),
          // ),
        ),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  // App Title & Logo
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset('lib/images/sp_final.png'),
                  ),
                  const SizedBox(height: 40),
                  // Welcome Message
                  Text(
                    'Welcome back!',
                    style: GoogleFonts.acme(fontSize: 22, color: Color(0xFF37474F)),
                  ),
                  Text(
                    'Let\'s go on remission!!',
                    style: GoogleFonts.acme(fontSize: 18, color: Color(0xFF37474F)),
                  ),
                  const SizedBox(height: 25),
                  // Email TextField
                  MyTextfield(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                    prefixIcon: const Icon(Icons.person),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  // Password TextField
                  MyTextfield(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 5),
                  // Forgot Password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Forgot Password?',
                          style: GoogleFonts.alice(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Login Button
                  MyButton(
                    text: "Login",
                    onTap: signUserIn,
                  ),
                  const SizedBox(height: 5),
                  const SizedBox(height: 45),
                  // Register Now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a member? ",
                        style: GoogleFonts.acme(
                          fontSize: 18,
                          color: Color(0xFF37474F),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Register now',
                          style: GoogleFonts.acme(
                            fontSize: 18,
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}