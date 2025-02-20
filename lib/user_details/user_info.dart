import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smartproductive_app/user_details/hobby_info.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String? selectedOccupation;

  // List of occupation options
  final List<String> occupations = [
    'Employee', 'Student', 'Worker', 'Doctor', 'Engineer', 'Farmer'
  ];

  void _validateAndProceed() async {
    if (nameController.text.isEmpty) {
      _showSnackBar("Please enter your Username.");
      return;
    }
    if (ageController.text.isEmpty) {
      _showSnackBar("Please enter your Age.");
      return;
    }
    if (selectedOccupation == null) {
      _showSnackBar("Please select an Occupation.");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing it manually
      builder: (context) => Center(
        child: LoadingAnimationWidget.inkDrop(
          color: Colors.white,
          size: 50,
        ),
      ),
    );

    // Simulate delay (optional, remove if not needed)
    await Future.delayed(Duration(seconds: 2));

    // Dismiss loading dialog
    Navigator.pop(context);

    // Navigate to HobbyInfo Page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HobbyInfo()),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xFF90E0EF),
          //title: Text("User Details")
      ),
      body: Container(
        decoration:BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF90E0EF), // Frosty blue
              Color(0xFF00B4D8), // Light aqua blue
              Color(0xFF0096C7), // Blue lagoon
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    'lib/user_details/user_images/user_img.png',
                    height: 315.3,
                  ),
                ),
                Text(
                  'Let\'s build your Profile!!',
                  style: GoogleFonts.aboreto(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
                const SizedBox(height: 10,),
                //Username
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Set Your Username",
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    fillColor: Colors.blue.shade100,
                    filled: true,
                    hintStyle: TextStyle(color: Colors.black45),
                  ),
                ),
                SizedBox(height: 10),
                //Age
                TextField(
                  controller: ageController,
                  decoration: InputDecoration(
                    hintText: "What is your Age ?",
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    fillColor: Colors.blue.shade100,
                    filled: true,
                    hintStyle: TextStyle(color: Colors.black45),
                  ),
                ),
                SizedBox(height: 10),
                //Occupation
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: "What's your Occupation ?",
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    fillColor: Colors.blue.shade100,
                    filled: true,
                    hintStyle: TextStyle(color: Colors.black45),
                  ),
                  value: selectedOccupation,
                  borderRadius: BorderRadius.circular(20),
                  items: occupations.map((occupation) {
                    return DropdownMenuItem(
                      value: occupation,
                      child: Text(occupation),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedOccupation = value;
                    });
                  },
                ),
                SizedBox(height: 14),
                //Button
                Align(
                  alignment: Alignment.topRight,
                  child: FloatingActionButton(
                    onPressed: (){
                      _validateAndProceed();
                      },
                    shape: CircleBorder(),
                    backgroundColor: Color(0xFF90E0EF),
                    child: Icon(
                      Icons.arrow_right_alt_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
