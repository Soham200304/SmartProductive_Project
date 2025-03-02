import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() {
              _isLoading = false; // Hide loading animation when page loads
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url)); // Load the article link
  }

  Widget _buildLoadingAnimation() {
    return Center(
      child: LoadingAnimationWidget.inkDrop(
        color: Colors.white,
        size: 50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.alike(fontSize: 24),
        ),
        backgroundColor: Color(0xFFB2F5B2),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFD0FFD0), // Gentle Minty Green
                  Color(0xFF90EE90), // Soft Light Green
                ],
              ),
            ),
            child: WebViewWidget(controller: _controller),
          ),
          if (_isLoading) _buildLoadingAnimation(), // Show animation while loading
        ],
      ),
    );
  }
}
