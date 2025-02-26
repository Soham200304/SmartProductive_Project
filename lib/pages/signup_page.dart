import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
            child: LoadingAnimationWidget.inkDrop(
              color: Colors.white,
              size: 50
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
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    //AppTitle
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset('lib/images/sp_final.png'),
                    ),
                    // Text(
                    //   "SmartProductive",
                    //   style: GoogleFonts.alike(fontSize: 45, fontWeight: FontWeight.bold,color: Colors.blue[100]),
                    // ),
                    const SizedBox(height: 40),
                    //welcome back, you've been missed
                    Text('Don\'t have an Account?',
                      style: GoogleFonts.acme(fontSize: 22, color: Colors.black),
                    ),
                    Text(
                      'SignUp Here!!',
                      style: GoogleFonts.acme(fontSize: 18, color: Colors.black),
                    ),
                    const SizedBox(height: 25),
                    //username TextField
                    MyTextfield(
                      controller: emailController,
                      hintText: "Email",
                      obscureText: false,
                      prefixIcon: const Icon(Icons.person),
                      keyboardType: TextInputType.emailAddress
                    ),
                    const SizedBox(height: 10),
                    //password text field
                    MyTextfield(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock),
                      keyboardType: TextInputType.text
                    ),
                    const SizedBox(height: 10),
                    //confirm password text field
                    MyTextfield(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 15),
                    //signin button
                    MyButton(
                      text:"Sign Up",
                      onTap: signUserUp,
                    ),

                    const SizedBox(height: 35),
                    //not a member? register now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an Account? ",
                          style: GoogleFonts.acme(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4,),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text('Login Now',
                            style: GoogleFonts.acme(

                              fontSize: 18,
                                color: Colors.white,
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
      ),
    );
  }
}
