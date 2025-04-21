import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartproductive_app/drawer_page/drawer.dart';

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
        backgroundColor: Colors.redAccent,
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
        backgroundColor: Color(0xFF9ADFFA),
        title: Text("Create a Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskNameController,
              decoration: InputDecoration(
                hintText: "Task Name",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Color(0xFF4FC3F7)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: "Task Description",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Color(0xFF4FC3F7)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4FC3F7)),
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4FC3F7)),
            onPressed: _addTask,
            child: Text("Create",style: TextStyle(color: Colors.black),),
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
        title: Text("Tasks",
        style: GoogleFonts.alike(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF4FC3F7),
      ),

      drawer: CustomDrawer(),

      body: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [
          //     Color(0xFFD0FFD0), // Gentle Minty Green
          //     Color(0xFF90EE90), // Soft Light Green
          //   ],
          // ),
          color: Color(0xFFFFF9F2),
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

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: snapshot.data!.docs.map((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  Color taskColor = Color(data['color']); // Convert stored color back to Color

                  return Dismissible(
                    key: Key(doc.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      _deleteTask(doc.id);
                    },
                    child: Card(
                      color: Color(0xFFCDE0F6),
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: taskColor, radius: 10,),
                        title: Text(data['taskName'],
                            style: GoogleFonts.aleo(fontWeight: FontWeight.bold, fontSize: 20)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['description'],
                                style: TextStyle(fontSize: 18),
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
              ),
            );
          },
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: _showCreateTaskDialog,
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color:  Color(0xFFFFA726),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(18)
          ),
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }
}
