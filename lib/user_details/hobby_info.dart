import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smartproductive_app/home_page/home_page.dart';

class HobbyInfo extends StatefulWidget {
  const HobbyInfo({super.key});

  @override
  State<HobbyInfo> createState() => _HobbyInfoState();
}

class _HobbyInfoState extends State<HobbyInfo> {
  final List<String> hobbies = [
    'Reading', 'Painting', 'Music', 'Cooking',
    'Dancing', 'Gaming', 'Photography', 'Gardening',
    'Writing', 'Fishing', 'Cycling', 'Traveling',
    'Swimming', 'Yoga', 'Coding'
  ];

  // Map each hobby to a specific icon
  final Map<String, IconData> hobbyIcons = {
    'Reading': Icons.menu_book,
    'Painting': Icons.brush,
    'Music': Icons.music_note,
    'Cooking': Icons.restaurant,
    'Dancing': Icons.sports_martial_arts,
    'Gaming': Icons.videogame_asset,
    'Photography': Icons.camera_alt,
    'Gardening': Icons.local_florist,
    'Writing': Icons.edit,
    'Fishing': Icons.pool,
    'Cycling': Icons.pedal_bike,
    'Traveling': Icons.flight,
    'Swimming': Icons.waves,
    'Yoga': Icons.self_improvement,
    'Coding': Icons.code,
  };

  final List<String> selectedHobbies = [];

  void _hobbyvalidation() async{
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
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF90E0EF),
      ),
      body: Container(
        decoration: BoxDecoration(
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
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Select Your Hobbies",
                  style: GoogleFonts.aboreto(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10,),

              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: hobbies.length,
                  itemBuilder: (context, index) {
                    final hobby = hobbies[index];
                    final isSelected = selectedHobbies.contains(hobby);
                    final icon = hobbyIcons[hobby] ?? Icons.question_mark; // Default icon if not found

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          isSelected
                              ? selectedHobbies.remove(hobby)
                              : selectedHobbies.add(hobby);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, size: 30), // Assign corresponding icon
                            SizedBox(height: 5),
                            Text(
                              hobby,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  LoadingAnimationWidget.inkDrop(color: Colors.white, size: 50);
                  if (selectedHobbies.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please select at least one hobby!"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  } else {
                    _hobbyvalidation();
                  }
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: Color(0xFF00B4D8),
                    ),
                    child: Center(
                      child: Text(
                        "Let\'s get started!",
                        style: GoogleFonts.abel(fontSize: 18),

                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

