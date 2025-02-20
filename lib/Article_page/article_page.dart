import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:smartproductive_app/Article_page/article_view.dart';
import 'package:smartproductive_app/home_page/home_page.dart';
import 'package:smartproductive_app/prod_buddy/prod_buddy.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smartproductive_app/task_page/task_pages.dart';

class ArticlePage extends StatefulWidget {
  const ArticlePage({super.key});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  List articles = [];

  // Function to load articles from local JSON file
  Future<void> loadArticles() async {
    String jsonString = await rootBundle.loadString('lib/assets/data.json');

    setState(() {
      articles = json.decode(jsonString);
      //print(articles);
    });
  }

  @override
  void initState() {
    super.initState();
    loadArticles(); // Load data when the page starts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Productivity Articles',
          style: GoogleFonts.alike(fontSize: 24),
        ),
        backgroundColor: Color(0xFFB2F5B2) // Very Soft Pastel Green,
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
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => TasksPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.article, size: 30),
                title: Text("A R T I C L E S"),
                onTap: () {
                  Navigator.pop(context);
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
        child: articles.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: articles.length,
          itemBuilder: (context, index) {
            return NewsCard(
              title: articles[index]['title'],
              imageUrl: articles[index]['imageUrl'] ?? 'https://via.placeholder.com/300x200',
              date: articles[index]['date'] ?? 'NULL',
              status: articles[index]['status'] ?? 'Productivity',
              link: articles[index]['link'],  // Pass article link from JSON
            );
          },
        ),
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String date;
  final String status;
  final String link;

  const NewsCard({
    required this.title,
    required this.imageUrl,
    required this.date,
    required this.status,
    required this.link,
  });

  // Function to load images from local assets or network
  Widget imageWidget(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: double.infinity,
        height: 200, // Set a fixed height
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.broken_image, size: 200),
      );
    } else {
      return Image.asset(
        path,
        width: double.infinity,
        height: 200, // Set a fixed height
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleWebView(url: link, title: title),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 200, // Ensure Stack has a height
            child: Stack(
              fit: StackFit.expand, // Expands to fill the SizedBox
              children: [
                // Background Image
                imageWidget(imageUrl),

                // Dark Gradient for Text Visibility
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Date
                Positioned(
                  top: 10,
                  left: 10,
                  child: Text(
                    date,
                    style: GoogleFonts.actor(color: Colors.white, fontSize: 14),
                  ),
                ),

                // Status
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.actor(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),

                // Title
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Text(
                    title,
                    style: GoogleFonts.actor(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
