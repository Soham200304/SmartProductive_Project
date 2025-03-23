import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smartproductive_app/components/my_button.dart';
import 'package:smartproductive_app/components/my_textfield.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatefulWidget {
  final Function()? onTap;
  const SignupPage({super.key, required this.onTap});

  @override
  State<SignupPage> createState() => _SignupPage();
}

class _SignupPage extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Function to sign up the user
  void signUserUp() async {
    // Show loading animation
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing while loading
      builder: (context) {
        return Center(
          child: LoadingAnimationWidget.inkDrop(color: Colors.white, size: 50),
        );
      },
    );

    try {
      if (passwordController.text.trim() == confirmPasswordController.text.trim()) {
        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final String uid = userCredential.user!.uid;

        // Save user email to Firestore
        await _firestore.collection('users').doc(uid).set({
          'user_id': uid,
          'email': emailController.text.trim(),
          'created_at': Timestamp.now(),
          'last_login': Timestamp.now(),
        });

        // Close loading animation ONLY IF the widget is still mounted
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          showErrorMessage("Passwords don't match!");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showErrorMessage(e.code);
      }
    }
  }

  // Error message pop-up
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
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
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [Color(0xFFD0FFD0), Color(0xFF90EE90)],
          // ),
          color: Color(0xFFFFF9F2)
        ),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset('lib/images/sp_final.png'),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Don\'t have an Account?',
                    style: GoogleFonts.acme(fontSize: 22, color: Color(0xFF37474F)),
                  ),
                  Text(
                    'Sign Up Here!!',
                    style: GoogleFonts.acme(fontSize: 18, color: Color(0xFF37474F)),
                  ),
                  const SizedBox(height: 25),

                  // Email
                  MyTextfield(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                    prefixIcon: const Icon(Icons.email),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),

                  // Password
                  MyTextfield(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 10),

                  // Confirm Password
                  MyTextfield(
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 15),

                  // Sign Up Button
                  MyButton(
                    text: "Sign Up",
                    onTap: signUserUp,
                  ),
                  const SizedBox(height: 35),

                  // Already have an account? Login Now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an Account? ",
                        style: GoogleFonts.acme(fontSize: 18, color: Color(0xFF37474F)),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Login Now',
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