import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rssreader/models/article.dart';
import 'package:rssreader/models/articles.dart';


class ArticlePage extends StatefulWidget {
  final Article article;

  ArticlePage(this.article);

  @override
  ArticlePageState createState() {
    return ArticlePageState(article);
  }
}

class ArticlePageState extends State<ArticlePage> {
  Article article;

  ArticlePageState(this.article);

  @override
  Widget build(BuildContext context) {

    return WebviewScaffold(
      url: article.link,
      withJavascript: false,
      appBar: AppBar(
        title: Text(article.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(article.link);
            },
          ),
          IconButton(
            icon: const Icon(Icons.launch),
            onPressed: () {
              launch(article.link);
            },
          ),
          IconButton(
            icon: Icon(article.isSaved ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              Articles articlesProvider = Provider.of<Articles>(context, listen: false);
              setState(() {
                article.isSaved = !article.isSaved;
              });
              if (article.isSaved) {
                articlesProvider.add(article);
              } else {
                articlesProvider.remove(article);
              }
            },
          )
        ],
      ),
    );
  }
}