import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartproductive_app/components/my_button.dart';
import 'package:smartproductive_app/components/my_textfield.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget{
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  //text editing controller

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  //sign userin
  void signUserIn() async{
    //show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 5,
              color: Colors.blue[700],
            ),
          );
        }
    );

    //try signin
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      );
      //pop the loading circle
      Navigator.pop(context);
    }on FirebaseAuthException catch (e) {
      //pop the loading circle
      Navigator.pop(context);
     //show error message
      showErrorMessage(e.code);
    }
  }

  //error message pop-up
  void showErrorMessage(String message) {
    showDialog(
        context: context,
        builder:(context) {
          return AlertDialog(
            backgroundColor: Colors.blue,
            title: Text(
              message,
              style: const TextStyle(fontSize: 25),
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      //backgroundColor: Colors.blue[300],
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
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  //AppTitle
                  Image.asset('lib/images/SmartProductivee_final_.png'),
                  // Text(
                  //   "SmartProductive",
                  //   style: GoogleFonts.alike(fontSize: 45, fontWeight: FontWeight.bold,color: Colors.blue[100]),
                  // ),
                  const SizedBox(height: 25),
                  //welcome back, you've been missed
                  Text('Welcome back!',
                    style: GoogleFonts.acme(fontSize: 22, color: Colors.black),
                  ),
                  Text(
                    'Let\'s go on remission!!',
                    style: GoogleFonts.acme(fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 25),
                  //username TextField
                  MyTextfield(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                    prefixIcon: const Icon(Icons.person),
                  ),
                  const SizedBox(height: 10),
                  //password text field
                  MyTextfield(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock),
                  ),

                  const SizedBox(height: 5),
                  //forgot password
                  const Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.black, decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  //signin button
                  MyButton(
                    text: "Login",
                    onTap: signUserIn,
                  ),

                  const SizedBox(height: 5),
                  //or continue with
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    // child: Row(
                    //   children: [
                    //     Expanded(
                    //       child: Divider(
                    //         thickness: 2.5,
                    //         color: Colors.blue[900],
                    //       ),
                    //     ),
                    //     Padding(
                    //       padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    //       child: Text('Or continue with',
                    //         style: TextStyle(color: Colors.blue[600]),
                    //       ),
                    //     ),
                    //     Expanded(
                    //       child: Divider(
                    //         thickness: 2.5,
                    //         color: Colors.blue[900],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ),
                  //google and x sign in options
                  // const SizedBox(height: 50),
                  // const Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     //google
                  //     FaIcon(
                  //       FontAwesomeIcons.google,
                  //       size:40,
                  //     ),
                  //     SizedBox(width: 28),
                  //     //x
                  //     FaIcon(
                  //       FontAwesomeIcons.xTwitter,
                  //       size:40,
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 45),
                  //not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Not a member? ",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 4,),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text('Register now',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration:TextDecoration.underline,
                            decorationColor: Colors.white
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
