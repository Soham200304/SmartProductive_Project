import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleWebView extends StatefulWidget {
  final String url;
  final String title;

  const ArticleWebView({Key? key, required this.url, required this.title}) : super(key: key);

  @override
  State<ArticleWebView> createState() => _ArticleWebViewState();
}

class _ArticleWebViewState extends State<ArticleWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));  // Load the article link
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(
        widget.title,
        style: GoogleFonts.alike(fontSize: 24),
      ),
      backgroundColor: Color(0xFF90E0EF),
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
          child: WebViewWidget(controller: _controller)
      ),
    );
  }
}
