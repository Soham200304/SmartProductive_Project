import 'package:flutter/material.dart';
import 'package:smartproductive_app/home_page/home_page.dart';

class ProdBuddy extends StatefulWidget {
  const ProdBuddy({super.key});

  @override
  State<ProdBuddy> createState() => _ProdBuddyState();
}

class _ProdBuddyState extends State<ProdBuddy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xFF90E0EF),
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xFF00B4D8),
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                    color: Color(0xFF00B4D8)
                ),
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
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProdBuddy()));
                },
              ),
              ListTile(
                leading: Icon(Icons.task, size: 30),
                title: Text('T A S K S'),
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
        decoration:BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF90E0EF), // Frosty blue
              Color(0xFF00B4D8), // Light aqua blue            ],
              Color(0xFF0096C7), // Blue lagoon
            ],
          ),
        ),
        child: Center(
          child: Text("This is Productive Buddy!!",
            style: TextStyle(
              fontSize: 25,
            ),
          ),
        ),
      ),
    );
  }
}
