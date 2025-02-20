import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smartproductive_app/Article_page/article_page.dart';
import 'package:smartproductive_app/home_page/home_page.dart';
import 'package:groq/groq.dart';
import 'package:smartproductive_app/task_page/task_pages.dart';


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
        "You are an helpful Task Suggesting AI Assistant where user inputs their current moods and feelings. The moods and feelings are 'Happy', 'Sad', 'Fear', 'Tiredness', 'Anger', 'Surprise', 'Exhaust', 'Confuse'. Your name is Motivo."+
            " Based on that you need to suggest some tasks and activities to do according to their mood. Suggest minimum 8 tasks to the user. Try not to give same responses for all set of moods and feelings" +
            "Also, You are an AI Assistant to give suggestions how to perform a dedicated hobby where user is in confuse state that how to cultivate their hobbies. In that situation, user inputs their hobby and asks suggestion from you how to cultivate their hobbies on a best way possible."+
            "You can suggest them 4  to 5 suggestions how to cultivate their hobbies. The user may ask you in this manner: My hobby is Coding but don't know how to cultivate it."+
            "The format for suggesting ways to cultivate hobby should have name of the suggestion, following with some description about the suggestion and state its advantages. Try not to give repeated suggestions across all other hobbies."+
            "The format for suggesting tasks should have name of the task and following with some description about that task." +
            "If user does not specify their moods / hobby or user greets you, you greet them in return asking them to input their mood / hobby."
    );
    final response = await _groq.sendMessage(message);
    return response.choices.first.message.content.replaceAll("*", "");
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
          isLoading = false; // Hide loading animation
          messages.add({"text": botResponse, "isUser": false}); // Sample bot response
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
        backgroundColor: Color(0xFF90EE90), // Soft Light Green
        elevation: 0,
        title: Text(
          textAlign: TextAlign.center,
          "Motivo",
          style: GoogleFonts.alike(fontSize: 21, fontWeight: FontWeight.bold),
        ),
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
                  Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomePage()));
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
                            SizedBox(width: 5),
                      _buildLoadingAnimation(),
                          ],
                        ),
                      ),
                    );
                  }
                  final message = messages[index];
                  return Align(
                    alignment: message["isUser"] ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: message["isUser"] ? EdgeInsets.only(left: 18.0) : EdgeInsets.only(right: 18.0),
                      child: Container(
                        padding: EdgeInsets.all(14),
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: message["isUser"] ? Colors.teal[200] : Colors.grey[200],
                          borderRadius: message["isUser"] ? BorderRadius.only(
                              bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20), topRight: Radius.zero, topLeft: Radius.circular(20))
                              :BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20), topRight: Radius.circular(20), topLeft: Radius.zero)
                        ),
                        child: Text(
                          message["text"],
                          style: GoogleFonts.aBeeZee(fontSize: 20),
                        ),
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
                      backgroundColor: Color(0xFFB2F5B2) // Very Soft Pastel Green
                      ,
                      onPressed: _sendMessage,
                      child: Icon(Icons.send, color: Color(0xFF5AAB61))
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
      color: Colors.white,
      size: 35,
    );
  }
}