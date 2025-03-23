import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartproductive_app/Article_page/article_page.dart';
import 'package:smartproductive_app/home_page/home_page.dart';
import 'package:smartproductive_app/prod_buddy/prod_buddy.dart';
import 'package:smartproductive_app/reports_page/reports_page.dart';
import 'package:smartproductive_app/store_page/store_page.dart';
import 'package:smartproductive_app/task_page/task_pages.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFFA1DFFA),
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFA1DFFA),),
              child: Center(child: Image.asset('lib/images/sp_final.png')),
            ),
            SizedBox(height: 10),
            _buildDrawerItem(
              context,
              icon: Icons.home,
              text: 'H O M E',
              page: HomePage(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.chat,
              text: 'M O T I V O',
              page: ProdBuddy(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.task,
              text: 'T A S K S',
              page: TasksPage(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.article,
              text: 'A R T I C L E S',
              page: ArticlePage(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.store,
              text: 'S T O R E S',
              page: StorePage(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.auto_graph_sharp,
              text: 'R E P O R T S',
              page: ReportsPage(), // Add page when implemented
            ),
            Divider(), // Adds a separator before logout
            _buildLogoutItem(context), // Logout button
          ],
        ),
      ),
    );
  }
  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String text, Widget? page}) {
    return Center(
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(text),
        onTap: () {
          Navigator.pop(context); // Close the drawer first

          if (page != null) {
            String currentRoute = ModalRoute.of(context)?.settings.name ?? "";
            String newRoute = page.runtimeType.toString();

            if (currentRoute == newRoute) {
              // If the user is already on the same page, just close the drawer
              return;
            }

            // Navigate only if it's a different page
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => page));
          }
        },
      ),
    );
  }
  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.logout, size: 30, color: Colors.black87),
      title: Text('L O G O U T', style: TextStyle(color: Colors.black87)),
      onTap: () async {
        // Show confirmation dialog before logging out
        bool confirmLogout = await _showLogoutDialog(context);
        if (confirmLogout) {
          await FirebaseAuth.instance.signOut();
        }
      },
    );
  }

  Future<bool> _showLogoutDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFB2F5B2),
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel", style: TextStyle(color: Colors.black),)
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Logout", style: TextStyle(color: Colors.black),),
          ),
        ],
      ),
    ) ?? false;
  }
}