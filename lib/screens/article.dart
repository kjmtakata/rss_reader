import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticlePage extends StatelessWidget {
  final String url;
  final String title;

  ArticlePage(this.url, this.title);

  @override
  Widget build(BuildContext context) {

    return WebviewScaffold(
      url: url,
      withJavascript: false,
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(url);
            },
          ),
          IconButton(
            icon: const Icon(Icons.launch),
            onPressed: () {
              launch(url);
            },
          )
        ],
      ),
    );
  }
}