import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:smartproductive_app/Second_page/second_page.dart';
import 'package:smartproductive_app/home_page/home_page.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    SecondPage(),
  ];

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.blue,
        buttonBackgroundColor: Colors.white,
        height: 60,
        animationDuration: Duration(milliseconds: 300),
        index: _selectedIndex,
        onTap: _navigateBottomBar,
        items: [
          Icon(Icons.home, size: 30, color: Colors.black),
          Icon(Icons.sports_esports, size: 30, color: Colors.black),
        ],
      ),
    );
  }
}
