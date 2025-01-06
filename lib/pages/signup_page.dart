import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartproductive_app/components/my_button.dart';
import 'package:smartproductive_app/components/my_textfield.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatefulWidget{
  final Function()? onTap;
  const SignupPage({super.key, required this.onTap});

  //text editing controller

  @override
  State<SignupPage> createState() => _SignupPage();
}

class _SignupPage extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //sign userin
  void signUserUp() async{
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
      //check if password is confirmed
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text
        );
      }
      else {
        //show error message of password does not matched
        showErrorMessage("Password doesn't match");
      }
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
              Color(0xFF0A85ED), // Inner color
              Color(0xFF2B2D42), // Outer color
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //AppTitle
                  Image.asset('lib/images/smartproductive_logo.png'),
                  // Text(
                  //   "SmartProductive",
                  //   style: GoogleFonts.alike(fontSize: 45, fontWeight: FontWeight.bold,color: Colors.blue[100]),
                  // ),
                  const SizedBox(height: 1),
                  //welcome back, you've been missed
                  Text('Don\'t have an Account?',
                    style: GoogleFonts.acme(fontSize: 25, color: Colors.white),
                  ),
                  Text(
                    'SignUp Here!!',
                    style: GoogleFonts.acme(fontSize: 18, color: Colors.white),
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
                  const SizedBox(height: 10),
                  //confirm password text field
                  MyTextfield(
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  const SizedBox(height: 10),
                  //forgot password
                  const SizedBox(height: 25),
                  //signin button
                  MyButton(
                    text:"Sign Up",
                    onTap: signUserUp,
                  ),

                  const SizedBox(height: 15),
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
                  const SizedBox(height: 15),
                  //not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an Account? ",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 4,),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text('Login Now',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                              decoration:TextDecoration.underline,
                              decorationColor: Colors.blue[700]
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
