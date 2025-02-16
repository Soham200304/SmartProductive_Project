import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:smartproductive_app/Article_page/article_page.dart';
import 'package:smartproductive_app/Second_page/second_page.dart';
import 'package:smartproductive_app/prod_buddy/prod_buddy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  double _timerValue = 10; // Initial timer value in seconds
  int _remainingTime = 10 * 60;
  Timer? _timer;
  bool _isRunning = false;
  bool _isMusicPlaying = false;
  bool _isSecondPage = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _selectedTag = "Study";
  Color _selectedTagColor = Colors.blue;
  List<Map<String, dynamic>> _customTasks = [
    {"name" : "Study", "color" : Colors.blue},
    {"name" : "Work", "color" : Colors.green},
    {"name" : "Social", "color" : Colors.purple},
    {"name" : "Rest", "color" : Colors.red}
  ];
  String _motivationText = "Start Working Today!";
  final List<String> _motivationQuotes = [
    "Keep pushing forward!",
    "You can do this!",
    "Focus on your goals!",
    "Stay determined!",
    "Hard work pays off!",
    "One step at a Time !",
    "Stay focused and never give up!",
    "You're doing great, keep going!"
  ];

  final String cloudinaryAudioUrl = "https://res.cloudinary.com/djhtg9chy/video/upload/v1739479052/focus_music_rbdlug.mp3";

  List<double> _checkpoints = [10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60];

  void _togglePage(bool value) {
    setState(() {
      _isSecondPage = value;
    });
    if (value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SecondPage()),
      );
    }
  }

  void _startOrCancelTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
        _remainingTime = _timerValue.toInt() * 60;
      });
      _showCancelDialog();
      _stopMusic();
    } else {
      setState(() {
        _remainingTime = _timerValue.toInt() * 60;
        _isRunning = true;
        _motivationText = _motivationQuotes[Random().nextInt(_motivationQuotes.length)];
      });

      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_remainingTime > 0) {
          setState(() {
            _remainingTime--;
            if (_remainingTime % 60 == 0) {
              _motivationText = _motivationQuotes[Random().nextInt(_motivationQuotes.length)];
            }
          });
        } else {
          timer.cancel();
          setState(() {
            _isRunning = false;
          });
          _showCompletionDialog();
          _stopMusic();
        }
      });
    }
  }

  void _toggleMusic() {
    if (_isMusicPlaying) {
      _stopMusic();
    } else {
      _playMusic();
    }
  }

  void _playMusic() async {
    try {
      await _audioPlayer.play(UrlSource(cloudinaryAudioUrl));

      setState(() {
        _isMusicPlaying = true;
      });
    } catch (e) {
      print("Error playing music: $e");
    }
  }


  void _stopMusic() async {
    await _audioPlayer.stop();
    setState(() {
      _isMusicPlaying = false;
    });
  }


  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF90E0EF),
          title: Text("Congratulations!!"),
          content: Text("You've focused for ${_timerValue.toInt()} minutes!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            )
          ],
        );
      },
    );
  }
  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF52C7F6),
        title: Text("You've stopped focusing"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
                "OK",
              style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, decorationColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showTagSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28), bottomRight: Radius.zero, bottomLeft: Radius.zero),
              color: Color(0xFF90E0EF),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ..._customTasks.map((task) => ListTile(
                      leading: CircleAvatar(backgroundColor: task["color"], radius: 5,),
                      title: Text(
                        task["name"],
                        style: TextStyle(
                          fontSize: 20
                        ),
                      ),
                      onTap: () => _setTag(task["name"], task["color"]),
                    )),
                    ListTile(
                      leading: Icon(Icons.add),
                      title: Text("Add Task"),
                      onTap: _showAddTaskDialog,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddTaskDialog() {
    TextEditingController taskController = TextEditingController();
    Color selectedColor = Colors.blue;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF90E0EF),
          title: Text("Add Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: InputDecoration(hintText: "Enter task name"),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ...[Colors.blue, Colors.green, Colors.purple, Colors.red].map((color) => GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: 10,
                    ),
                  )),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _customTasks.add({"name": taskController.text, "color": selectedColor});
                });
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _setTag(String tag, Color color) {
    setState(() {
      _selectedTag = tag;
      _selectedTagColor = color;
    });
    Navigator.pop(context);
  }

  // Sign user out
  void signuserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF90E0EF),
        actions: [
          Align(
            alignment: Alignment.center,
            child: Center(
              child: Switch(
                value: _isSecondPage,
                onChanged: _togglePage,
              ),
            ),
          ),
          if (_isRunning)
            IconButton(
              onPressed: _toggleMusic,
              icon: Icon(_isMusicPlaying ? Icons.music_off : Icons.music_note, size: 28),
            ),
          IconButton(
            onPressed: signuserOut,
            icon: Icon(Icons.logout, size: 28),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xFF00B4D8),
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF00B4D8)),
                child: Center(child: Image.asset('lib/images/sp_final.png')),
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.home, size: 30),
                title: Text('H O M E'),
                onTap: () {
                  Navigator.pop(context); // Close drawer instead of pushing a new HomePage
                },
              ),
              ListTile(
                leading: Icon(Icons.chat, size: 30),
                title: Text('P - B U D D Y'),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => ProdBuddy()));
                },
              ),
              ListTile(
                leading: Icon(Icons.article, size: 30),
                title: Text("A R T I C L E S"),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => ArticlePage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.auto_graph_sharp, size: 30),
                title: Text('R E P O R T S'),
              ),
              ListTile(
                leading: Icon(Icons.settings, size: 30),
                title: Text('S E T T I N G S'),
              ),
            ],
          ),
        ),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _motivationText,
                style: GoogleFonts.actor(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              SleekCircularSlider(
                initialValue: _timerValue,
                min: _checkpoints.first,
                max: _checkpoints.last,
                appearance: CircularSliderAppearance(
                  size: 250,
                  startAngle: 270,
                  angleRange: 360,
                  customWidths: CustomSliderWidths(progressBarWidth: 10, handlerSize: 12,trackWidth: 10),
                  customColors: CustomSliderColors(progressBarColor: Colors.blue[600], trackColor: Colors.blue[300]),
                ),
                onChange: _isRunning
                 ? null
                : (value) {
                  double closestCheckpoint = _checkpoints.reduce((a, b) => (value - a).abs() < (value - b).abs() ? a : b);
                  setState(() {
                    _timerValue = closestCheckpoint;
                    _remainingTime = closestCheckpoint.toInt() * 60;
                  });
                },
                innerWidget: (value) => Center(
                  child: Container(
                    width: 230.0,
                    height: 230.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x5790E0EF),
                    ),
                    child: Center(
                      child: Text(
                        "${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${( _remainingTime % 60).toString().padLeft(2, '0')}",
                        style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 35),
              GestureDetector(
                onTap: _showTagSelector,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(0x4AFDFDFD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circular color tag
                      Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: _selectedTagColor, // The corresponding color of the tag
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 10), // Space between tag and text
                      Text(
                        _selectedTag,
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),
              GestureDetector(
                onTap: _startOrCancelTimer,
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(28),
                    color: _isRunning ? Colors.red[100] : Color(0xFF52C7F6),
                     boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius:5,
                      offset: Offset(3, 3), // changes position of shadow
                    ),
                  ],
                  ),
                  height: 50,
                  width: 135,
                  child: Center(
                    child: Text(
                      _isRunning ? "Stop" : "Start",
                      style: GoogleFonts.acme(fontSize: 25, color: Colors.black),
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

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
