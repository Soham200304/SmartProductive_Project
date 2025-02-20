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
import 'package:smartproductive_app/task_page/task_pages.dart';

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


  // void _showCompletionDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         backgroundColor: Color(0xFF90E0EF),
  //         title: Text("Congratulations!!"),
  //         content: Text("You've focused for ${_timerValue.toInt()} minutes!"),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: Text("OK"),
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }
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

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF90E0EF),
          title: Text("Congratulations!!"),
          content: Text("You've focused for ${_timerValue.toInt()} minutes!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showBreakDialog(); // Ask for break
              },
              child: Text("OK"),
            )
          ],
        );
      },
    );
  }

  void _showBreakDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF90E0EF),
          title: Text("Select Break Duration"),
          content: Wrap(
            spacing: 10,
            children: List.generate(10, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _timerValue = index + 1; // Set break duration
                    _remainingTime = _timerValue.toInt() * 60;
                    _isRunning = true;
                  });
                  Navigator.pop(context);
                  _startBreakTimer();
                },
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text("${index + 1}", style: TextStyle(color: Colors.white)),
                ),
              );
            }),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showCancelBreakDialog();
              },
              child: Text("Cancel Break"),
            ),
          ],
        );
      },
    );
  }

  void _showCancelBreakDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF52C7F6),
          title: Text("Are you sure?"),
          content: Text("Do you want to skip the break and continue?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showBreakDialog(); // Redirect back to break selection
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isRunning = true;
                  _remainingTime = _timerValue.toInt() * 60; // Resume last focus timer
                });
                Navigator.pop(context);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _startBreakTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isRunning = false;
        });
        _showPostBreakDialog();
      }
    });
  }

  void _showPostBreakDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF90E0EF),
          title: Text("Break Over"),
          content: Text("Would you like to start another focus session?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startOrCancelTimer(); // Restart focus session
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  void _navigateToTasksPage() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TasksPage(
          // onTaskSelected: (taskName, taskColor) {
          //   setState(() {
          //     _selectedTag = taskName;
          //     _selectedTagColor = taskColor;
          //   });
          // },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB2F5B2), // Very Soft Pastel Green
        actions: [
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
          color: Color(0xFFB2F5B2), // Very Soft Pastel Green
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF90EE90)),
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
                leading: Icon(Icons.task, size: 30),
                title: Text("T A S K S"),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => TasksPage()));
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
              Color(0xFFD0FFD0), // Gentle Minty Green
              Color(0xFFB2F5B2), // Very Soft Pastel Green
              Color(0xFF90EE90), // Soft Light Green
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
                initialValue: _timerValue.clamp(_checkpoints.first, _checkpoints.last), // Ensure value is valid
                min: _checkpoints.first,
                max: _checkpoints.last,
                appearance: CircularSliderAppearance(
                  size: 250,
                  startAngle: 270,
                  angleRange: 360,
                  customWidths: CustomSliderWidths(progressBarWidth: 10, handlerSize: 12,trackWidth: 10),
                  customColors: CustomSliderColors(progressBarColor: Color(0xFF90EE90), trackColor: Color(0xFF90EE90)),
                ),
                onChange: _isRunning
                 ? null
                : (value) {
                  double closestCheckpoint = _checkpoints.reduce((a, b) => (value - a).abs() < (value - b).abs() ? a : b);
                  setState(() {
                    _timerValue = _checkpoints.reduce((a, b) => (a - 10).abs() < (b - 10).abs() ? a : b);
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
                onTap: _navigateToTasksPage,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF5AAB61)),
                    color: Color(0x4AD1CFCF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: _selectedTagColor, // The corresponding color of the tag
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        _selectedTag,
                        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
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
                    color: _isRunning ? Colors.red[100] : Color(0xFF90EE90) // Soft Light Green
                    ,
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
