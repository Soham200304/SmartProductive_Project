import 'package:flutter/material.dart';
import 'package:smartproductive_app/pages/login_page.dart';
import 'package:smartproductive_app/pages/signup_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {

  //initially show login page
  bool showLoginPage = true;

  //toggle between login and register page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(showLoginPage){
      return LoginPage(
        onTap: togglePages,
      );
    }
    else{
      return SignupPage(
        onTap: togglePages,
      );
    }
  }
}
