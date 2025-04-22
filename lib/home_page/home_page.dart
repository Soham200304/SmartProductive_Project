import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  int _coins = 0;
  String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
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

  String cloudinaryAudioUrl = "https://res.cloudinary.com/djhtg9chy/video/upload/v1739479052/focus_music_rbdlug.mp3";

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

  @override
  void initState() {
    super.initState();
    _fetchUserCoins();
  }

  /// Fetch user's current coins from Firebase
  Future<void> _fetchUserCoins() async {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? ""; // Get the current user's ID

      if (userId.isEmpty) return; // Ensure userId is valid

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      setState(() {
        _coins = userDoc.exists ? (userDoc['coins'] ?? 0) : 0;
      });
  }

  Future<void> _rewardCoins(int coinsEarned) async {
    try {
      // Get the current user ID
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("User is not logged in.");
        return;
      }

      String userId = user.uid; // Get UID

      // Ensure Firestore document exists before updating
      DocumentReference userRef =
      FirebaseFirestore.instance.collection('users').doc(userId);

      await userRef.set({'coins': FieldValue.increment(coinsEarned)}, SetOptions(merge: true));

      print("Coins updated successfully!");

    } catch (e) {
      print("Error updating coins: $e");
    }
  }

  /// Calculate coin rewards based on time focused
  int _calculateCoins(int focusedMinutes) {
    if (focusedMinutes >= 55) return 10;
    if (focusedMinutes >= 35) return 9;
    if (focusedMinutes >= 20) return 7;
    if (focusedMinutes >= 10) return 3;
    return 0;
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
          _onTimerComplete();
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

  void _showMusicSelectionDialog(BuildContext context) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(userId).get();

    List<dynamic> unlockedMusic = userDoc["unlockedMusic"] ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF7DC8F3), // Ocean Blue (Primary)
        title: Text("Select Focus Sound"),
        content: unlockedMusic.isEmpty
            ? Text("No unlocked sounds yet.")
            : Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: unlockedMusic.length,
            itemBuilder: (context, index) {
              String url = unlockedMusic[index];
              return ListTile(
                title: Text("Music ${index + 1}"),
                onTap: () {
                  setState(() {
                    cloudinaryAudioUrl = url; // Save selected URL
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }


  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF4FC3F7), // Ocean Blue (Primary),
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
              color: Color(0xFF4FC3F7)
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
                        leading: CircleAvatar(backgroundColor: taskColor, radius: 10),
                        title: Text(
                          task["taskName"],
                          style: TextStyle(fontSize: 22),
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

  void _onTimerComplete() async {
    setState(() {
      _isRunning = false; // Enable tag selection again
    });

    int focusedMinutes = (_timerValue.toInt() * 60 - _remainingTime) ~/ 60;
    int coinsEarned = _calculateCoins(focusedMinutes);

    // Update Firebase with new coin balance
    await FirebaseFirestore.instance.collection('users')
        .doc(userId)
        .update({
      'coins': FieldValue.increment(coinsEarned),
    });

    setState(() {
      _coins += coinsEarned;
    });

    // Store completion time
    _storeCompletionTime(_selectedTag);

    _showCompletionDialog(focusedMinutes, coinsEarned);

    int earnedCoins = _calculateCoins(_timerValue.toInt()); // Calculate coins
    _rewardCoins(earnedCoins); // Update Firestore
  }

  void _showCompletionDialog(int focusedMinutes, int coinsEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF4FC3F7), // Ocean Blue (Primary)
          title: Text("Congratulations!!"),
          content: Text(
            "You've focused for $focusedMinutes minutes on $_selectedTag!\n"
                "Coins Earned: $coinsEarned",
          ),
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
          backgroundColor: Color(0xFF4FC3F7), // Ocean Blue (Primary)
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
                      color: Color(0xFFFFA726),
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
          backgroundColor: Color(0xFF4FC3F7),
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
          backgroundColor: Color(0xFF4FC3F7),
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
        backgroundColor: Color(0xFF4FC3F7), // Ocean Blue (Primary)
        //iconTheme: IconThemeData(color: Color(0xFF37474F)), // Deep Gray-Blue icons
        actions: [
          if (_isRunning)
            GestureDetector(
              onLongPress: () => _showMusicSelectionDialog(context),
              child: IconButton(
                onPressed: _toggleMusic,
                icon: Icon(
                  _isMusicPlaying ? Icons.music_off : Icons.music_note,
                  size: 28,
                ),
              ),
            ),
          // Coin Display - Hide when timer is running
          if (!_isRunning)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.coins, color: Colors.amber, size: 30),
                  SizedBox(width: 8),
                  Text("$_coins", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
      drawer: CustomDrawer(),
      
      body: Container(
        decoration: BoxDecoration(
        color: Color(0xFFFFF9F2),
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
                  customColors: CustomSliderColors(progressBarColor: Color(0xFFFFA726), trackColor: Color(0xFF37474F)),
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
                      color: Color(0xB4FC3F7),
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
                    border: Border.all(color: Color(0xFF4FC3F7)),
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
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                    color: _isRunning ? Colors.red[100] : Color(0xFF4FC3F7), // Ocean Blue (Primary)
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
