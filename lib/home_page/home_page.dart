import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartproductive_app/drawer_page/drawer.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _selectedTag = "Study";
  Color _selectedTagColor = Colors.blue;
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

  void storeTimerCompletion() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    String? userId = auth.currentUser?.uid;
    if (userId == null) return; // Ensure the user is logged in

    await firestore.collection('users') // Main Collection
        .doc(userId) // Document for the specific user
        .collection('timers') // Subcollection for timers
        .add({ // Add a new document with auto-generated ID
      'completionTime': FieldValue.serverTimestamp(), // Store the current time
    });

    print("Timer completion time stored successfully!");
  }

  void _startOrCancelTimer() {
    if (_isRunning) {
      // Cancel the timer if it's already running
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

      // Start the timer and call _onTimerComplete() when finished
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
          // Call _onTimerComplete() when the timer finishes
          _showCompletionDialog();
          _stopMusic();
        }
      });
    }
  }

  void _storeCompletionTime(String taskName) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance.collection('timerCompletions').add({
      'userId': userId,
      'completedAt': FieldValue.serverTimestamp(),
      'completedTime': DateTime.now().toLocal().toString(), // Store local time
      'timer': _timerValue,
      'taskName': taskName,
    });
    print("Timer completion stored for task: $taskName");
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

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFD0FFD0),
        title: Text("You've stopped focusing"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
                "OK",
              style: TextStyle(
                  color: Colors.blue[900],
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.black
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTagSelector() {
    if (_isRunning) {
      _showSnackBar("Cannot change task while timer is running!");
      return; // Exit function if timer is running
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
              color: Color(0xFFD0FFD0),
            ),
            child: SafeArea(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No tasks available. Create one first!"));
                  }
                  return ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> task = doc.data() as Map<String, dynamic>;
                      Color taskColor = Color(task['color']); // Convert stored color
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: taskColor, radius: 5),
                        title: Text(
                          task["taskName"],
                          style: TextStyle(fontSize: 20),
                        ),
                        onTap: () => _setTag(task["taskName"], taskColor),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        );
      },
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

  void _setTag(String tag, Color color) {
    setState(() {
      _selectedTag = tag;
      _selectedTagColor = color;
    });
    Navigator.pop(context);
  }

  void _showCompletionDialog() {
    setState(() {
      _isRunning = false; // Enable tag selection again
    });

    // Store the completion time along with the selected task name
    _storeCompletionTime(_selectedTag);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFD0FFD0),
          title: Text("Congratulations!!"),
          content: Text("You've focused for ${_timerValue.toInt()} minutes on $_selectedTag!"),
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
          backgroundColor: Color(0xFFD0FFD0),
          title: Text("Select Break Duration"),
          content: Wrap(
            spacing: 10,
            children: List.generate(10, (index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _startBreakTimer((index + 1) * 60); // Pass seconds instead of minutes
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xFF00A86B), // Better color contrast
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text("${index + 1}", style: TextStyle(color: Colors.white)),
                  ),
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
          backgroundColor: Color(0xFFD0FFD0),
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
                if (_timer != null) {
                  _timer!.cancel(); // Ensure previous timer is stopped
                }
                setState(() {
                  _isRunning = false; // Stop the break mode
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

  void _startBreakTimer(int breakDuration) {
    if (_timer != null) {
      _timer!.cancel(); // Ensure any previous timer is stopped
    }

    setState(() {
      _remainingTime = breakDuration;
      _isRunning = true;
    });

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
          backgroundColor: Color(0xFFD0FFD0),
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
        ],
      ),
      drawer: CustomDrawer(),
      
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
                  customColors: CustomSliderColors(progressBarColor: Color(0xFF90EE90), trackColor: Color(
                      0x9890EE90)),
                ),
                onChange: _isRunning
                 ? null
                : (value) {
                  double closestCheckpoint = _checkpoints.reduce((a, b) => (value - a).abs() < (value - b).abs() ? a : b);
                  setState(() {
                    _timerValue = closestCheckpoint;
                    _remainingTime = (_timerValue.toInt() * 60);
                  });
                },
                innerWidget: (value) => Center(
                  child: Container(
                    width: 230.0,
                    height: 230.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x1F90E0EF),
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
