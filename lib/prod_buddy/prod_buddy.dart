import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smartproductive_app/drawer_page/drawer.dart';
import 'package:groq/groq.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ProdBuddy extends StatefulWidget {
  const ProdBuddy({super.key});
  @override
  State<ProdBuddy> createState() => _ProdBuddyState();
}

class _ProdBuddyState extends State<ProdBuddy> {
  TextEditingController _controller = TextEditingController(); // Controller to manage text input
  List<Map<String, dynamic>> messages = []; // Stores messages with sender info
  final ScrollController _scrollController = ScrollController(); // Controller to manage scrolling
  bool isLoading = false; // Tracks loading state
  late StreamSubscription<QuerySnapshot> _chatSubscription;

  Future<String> groq_model(String message) async {
    final _groq = Groq(apiKey:'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', model: "llama-3.3-70b-versatile");
    _groq.startChat();
    _groq.setCustomInstructionsWith(
        "You are an helpful Task Suggesting AI Assistant where user inputs their current moods and feelings. The moods and feelings are 'Happy', 'Sad', 'Fear', 'Tiredness', 'Anger', 'Surprise', 'Exhaust', 'Confuse'. Your name is Motivo."+
            " Based on that you need to suggest some tasks and activities to do according to their mood. Suggest minimum 8 tasks to the user. Try not to give same responses for all set of moods and feelings" +
            "Also, You are an AI Assistant to give suggestions how to perform a dedicated hobby where user is in confuse state that how to cultivate their hobbies. In that situation, user inputs their hobby and asks suggestion from you how to cultivate their hobbies on a best way possible."+
            "You can suggest them 4  to 5 suggestions how to cultivate their hobbies. The user may ask you in this manner: My hobby is Coding but don't know how to cultivate it."+
            "The format for suggesting ways to cultivate hobby should have name of the suggestion, following with some description about the suggestion and state its advantages. Try not to give repeated suggestions across all other hobbies."+
            "The format for suggesting tasks should have name of the task and following with some description about that task." +
            "If user does not specify their moods / hobby or user greets you, you greet them in return asking them to input their mood / hobby." +
            "If user Thanks you for your help, you should greet them in return and give assurance that you'll be there in future."
    );
    final response = await _groq.sendMessage(message);
    return response.choices.first.message.content.replaceAll("*", "");
  }

  @override
  void initState() {
    super.initState();
    _loadMessages(); // Fetch messages from Firebase on app start
  }


  void _sendMessage() async {
    String message = _controller.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        messages.add({"text": message, "isUser": true});
        isLoading = true;
      });
      _controller.clear();
      _scrollToBottom();
      _saveMessageToFirestore(message, true);

      Future.delayed(Duration(seconds: 2), () async {
        String botResponse = await groq_model(message);
        setState(() {
          isLoading = false;
          messages.add({"text": botResponse, "isUser": false});
        });
        _saveMessageToFirestore(botResponse, false);
        _scrollToBottom();
      });
    }
  }

  void _saveMessageToFirestore(String text, bool isUser) async {
    User? user = FirebaseAuth.instance.currentUser; // Get current logged-in user
    if (user == null) return;

    await FirebaseFirestore.instance.collection('chats').add({
      'userId': user.uid, // Associate message with logged-in user
      'text': text,
      'isUser': isUser,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _loadMessages() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _chatSubscription = FirebaseFirestore.instance
        .collection('chats')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;

      setState(() {
        messages = snapshot.docs.map((doc) {
          return {
            "text": doc["text"],
            "isUser": doc["isUser"],
            "timestamp": doc["timestamp"] != null
                ? (doc["timestamp"] as Timestamp).toDate()
                : DateTime.now(),
          };
        }).toList();
      });
    });
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String formatDate(DateTime date) {
    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(Duration(days: 1));

    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return "Today";
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return "Yesterday";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4FC3F7),
        elevation: 0,
        title: Text(
          textAlign: TextAlign.center,
          "Motivo",
          style: GoogleFonts.alike(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: CustomDrawer(),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFFF9F2),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length && isLoading) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 5,),
                            _buildLoadingAnimation(),
                          ],
                        ),
                      ),
                    );
                  }

                  final message = messages[index];
                  DateTime messageDate = message["timestamp"] ?? DateTime.now();
                  String formattedDate = formatDate(messageDate);

                  // Check if the previous message had a different date
                  bool showDateHeader = index == 0 ||
                      formatDate(messages[index - 1]["timestamp"]) != formattedDate;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (showDateHeader)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            height: 20,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                formattedDate,
                                style: GoogleFonts.aBeeZee(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Align(
                        alignment: message["isUser"] ? Alignment.centerRight : Alignment.centerLeft,
                        child: Padding(
                          padding: message["isUser"] ? EdgeInsets.only(left: 18.0) : EdgeInsets.only(right: 18.0),
                          child: Container(
                            padding: EdgeInsets.all(14),
                            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: message["isUser"] ? Color(0xFFA3DEF8) : Colors.grey[200],
                              borderRadius: message["isUser"]
                                  ? BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topRight: Radius.zero,
                                  topLeft: Radius.circular(20))
                                  : BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  topLeft: Radius.zero),
                            ),
                            child: Text(
                              message["text"],
                              style: GoogleFonts.aBeeZee(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        cursorColor: Colors.blue,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    FloatingActionButton(
                      backgroundColor: Color(0xFF4FC3F7),
                      elevation: 0,
                      onPressed: _sendMessage,
                      child: Icon(Icons.send, color: Color(0xFF264DEC))
                      ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget _buildLoadingAnimation() {
    return LoadingAnimationWidget.waveDots(
      color: Colors.black,
      size: 35,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _chatSubscription.cancel();
    super.dispose();
  }
}