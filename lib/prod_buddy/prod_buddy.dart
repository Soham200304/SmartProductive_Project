import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartproductive_app/Article_page/article_page.dart';
import 'package:smartproductive_app/home_page/home_page.dart';
import 'package:groq/groq.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

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


  Future<String> groq_model(String message) async {
    final _groq = Groq(apiKey:'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', model: "llama-3.3-70b-versatile");
    _groq.startChat();
    _groq.setCustomInstructionsWith(
        "You are an helpful Task Suggesting AI Assistant where user inputs their current moods and feelings. Your name is Motivo."+
            " Based on that you need to suggest some tasks and activities to do according to their mood. Suggest minimum 8 tasks to the user." +
            "The format should have name of the task and following with some description about that task." +
            "If user does not specify their moods or user greets you, you greet them in return asking them to input their mood."
    );
    final response = await _groq.sendMessage(message);
    return response.choices.first.message.content;
  }

  void _sendMessage() async {
    String message = _controller.text.trim(); // Get input text and remove whitespace
    if (message.isNotEmpty) {
      setState(() {
        messages.add({"text": message, "isUser": true}); // Add user message
        isLoading = true; // Show loading animation
      });
      _controller.clear(); // Clear input field after sending
      _scrollToBottom(); // Scroll down to the latest message

      // Await the response from the Groq API
      String botResponse = await groq_model(message);

      // Add the bot's response to the messages list
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          //isLoading = false; // Hide loading animation
          messages.add({"text": "Here is your productivity tip! Stay focused and take breaks.", "isUser": false}); // Sample bot response
        });
        _scrollToBottom();
      });
    }
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
  // void _saveMessages() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString('chatMessages', jsonEncode(messages));
  // }
  //
  // void _loadMessages() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? storedMessages = prefs.getString('chatMessages');
  //   if (storedMessages != null) {
  //     setState(() {
  //       messages = List<Map<String, dynamic>>.from(jsonDecode(storedMessages));
  //     });
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF90E0EF),
        elevation: 0,
        title: Text(
          textAlign: TextAlign.center,
          "                Motivo",
          style: GoogleFonts.alike(fontSize: 20, fontWeight: FontWeight.bold),
        ),
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
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.chat, size: 30),
                title: Text('P - B U D D Y'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.article, size: 30),
                title: Text("A R T I C L E S"),
                onTap: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ArticlePage()));
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
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  if (index == messages.length && isLoading) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Bot is typing..."),
                            SizedBox(width: 5),
                            SizedBox(
                              width: 40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildDot(),
                                  _buildDot(delay: 200),
                                  _buildDot(delay: 400),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final message = messages[index];
                  return Align(
                    alignment: message["isUser"] ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        color: message["isUser"] ? Colors.blue[300] : Colors.grey[300],
                        borderRadius: message["isUser"] ? BorderRadius.only(
                            bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20), topRight: Radius.zero, topLeft: Radius.circular(20))
                            :BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20), topRight: Radius.circular(20), topLeft: Radius.zero)
                      ),
                      child: Text(
                        message["text"],
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
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
                      backgroundColor: Color(0xFF90E0EF),
                      onPressed: _sendMessage,
                      child: Icon(Icons.send, color: Color(0xFF0096C7),),
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
  Widget _buildDot({int delay = 0}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Opacity(
          opacity: (value * 2 - 1).abs(),
          child: child,
        );
      },
      onEnd: () {
        setState(() {});
      },
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}