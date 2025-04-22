import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartproductive_app/about_us/about_us.dart';
import 'package:smartproductive_app/drawer_page/drawer.dart';
import 'package:smartproductive_app/help_and_support/help_and_support.dart';
import 'package:smartproductive_app/social_media/social_media.dart';

class InfoSettingsPage extends StatelessWidget {
  const InfoSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Info',
            style: GoogleFonts.alike(
                fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: const Color(0xFF4FC3F7),
      ),
      drawer: CustomDrawer(),
      body: Container(
        color: Color(0xFFFFF9F2),
        child: ListView(
          children: [
            _buildTile(
              context,
              icon: Icons.info_outline,
              title: 'About Us',
              navigateTo:AboutUs()
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            _buildTile(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              navigateTo: HelpAndSupport(),
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            _buildTile(
              context,
              icon: Icons.share,
              title: 'Social Media',
              navigateTo: const SocialMedia(),
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context,
      {required IconData icon,
        required String title,
        required Widget navigateTo}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(icon, size: 30, color: Color(0xFFFFA726)),
        title: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Text(title, style: TextStyle(fontSize: 18)),
        ),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => navigateTo)),
      ),
    );
  }
}
