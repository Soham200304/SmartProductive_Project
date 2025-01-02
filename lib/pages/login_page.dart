import 'package:flutter/material.dart';
import 'package:smartproductive_app/components/my_button.dart';
import 'package:smartproductive_app/components/my_textfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatelessWidget{
  LoginPage({super.key});

  //text editing controller

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  //sign userin
  void signUserIn(){

  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.blue[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //AppTitle
                Text(
                  "SmartProductive",
                  style: GoogleFonts.alike(fontSize: 50, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 50),
                //welcome back, you've been missed
                Text('Welcome back!',
                  style: GoogleFonts.acme(fontSize: 25),
                ),
                Text(
                  'you\'ve been missed!',
                  style: GoogleFonts.acme(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 25),
                //username TextField
                MyTextfield(
                  controller: usernameController,
                  hintText: "Username",
                  obscureText: false,
                ),

                const SizedBox(height: 10),
                //password text field
                MyTextfield(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),

                const SizedBox(height: 10),
                //forgot password
                const Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Forgot Password?',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                //signin button
                MyButton(
                  onTap: signUserIn,
                ),

                const SizedBox(height: 50),
                //or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 2.5,
                          color: Colors.blue[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('Or continue with',
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 2.5,
                          color: Colors.blue[400],
                        ),
                      ),
                    ],
                  ),
                ),
                //google and x sign in options
                const SizedBox(height: 50),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //google
                    FaIcon(
                      FontAwesomeIcons.google,
                      size:40,
                    ),
                    SizedBox(width: 28),
                    //x
                    FaIcon(
                      FontAwesomeIcons.xTwitter,
                      size:40,
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                //not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Not a member? ",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4,),
                    Text('Register now',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                      ),

                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
