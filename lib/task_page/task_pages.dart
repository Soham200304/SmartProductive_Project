import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartproductive_app/Article_page/article_page.dart';
import 'package:smartproductive_app/home_page/home_page.dart';
import 'package:smartproductive_app/prod_buddy/prod_buddy.dart';

class TasksPage extends StatefulWidget {
  TasksPage({super.key});

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange
  ];

  // Function to generate a random color
  Color _getRandomColor() {
    return _availableColors[Random().nextInt(_availableColors.length)];
  }

  // Function to add task to Firestore
  void _addTask() async {
    String taskName = _taskNameController.text.trim();
    String description = _descriptionController.text.trim();
    String? userId = _auth.currentUser?.uid;

    if (taskName.isNotEmpty && description.isNotEmpty && userId != null) {
      Color taskColor = _getRandomColor();

      await _firestore.collection('tasks').add({
        'userId': userId,
        'taskName': taskName,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'color': taskColor.value, // Store color as int
      });

      _taskNameController.clear();
      _descriptionController.clear();
      Navigator.pop(context);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green, // ✅ Green color for success
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Function to delete a task
  void _deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
    _showSnackBar('Task Deleted');
  }

  // Show Dialog to Create a Task
  void _showCreateTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Create Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskNameController,
              decoration: InputDecoration(labelText: "Task Name"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: "Task Description"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _addTask,
            child: Text("Create"),
          ),
        ],
      ),
    );
  }

  // Fetch tasks for logged-in user
  Stream<QuerySnapshot> fetchTasks() {
    String? userId = _auth.currentUser?.uid;

    if (userId == null) {
      return Stream.empty(); // Return empty stream if user is not logged in
    }

    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks"),
        backgroundColor: Color(0xFF90EE90), // Soft Light Green,
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
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => ProdBuddy()));
                },
              ),
              ListTile(
                leading: Icon(Icons.task, size: 30),
                title: Text("T A S K S"),
                onTap: () {
                  Navigator.pop(context);
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
        child: StreamBuilder(
          stream: fetchTasks(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No tasks yet. Create a new one!"));
            }

            return ListView(
              children: snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                Color taskColor = Color(data['color']); // Convert stored color back to Color

                return Dismissible(
                  key: Key(doc.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _deleteTask(doc.id);
                  },
                  child: Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: taskColor),
                      title: Text(data['taskName'],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['description'],
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 5),
                          Text(
                            "Created: ${data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toString() : 'N/A'}",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTaskDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
