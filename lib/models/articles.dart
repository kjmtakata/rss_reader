import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webfeed/webfeed.dart';

import 'package:rssreader/models/article.dart';
import 'package:rssreader/models/feed.dart';
import 'package:rssreader/models/feeds.dart';

class Articles extends ChangeNotifier {
  static final String savedArticlesKey = "saved_articles";
  List<Article> savedArticles = [];
  List<Article> articles = [];

  Future load(BuildContext context) async {
    articles.clear();
    savedArticles.clear();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (!prefs.containsKey(savedArticlesKey)) {
      await prefs.setStringList(savedArticlesKey, []);
    }
    for (String feedJson in prefs.getStringList(savedArticlesKey)) {
      savedArticles.add(Article.fromJson(jsonDecode(feedJson)));
    }

    Feeds feedsProvider = Provider.of<Feeds>(context, listen: false);
    await feedsProvider.load();
    for (Feed feed in feedsProvider.getAll()) {
      print("refreshing feed: " + feed.url);
      http.Response response = await http.get(feed.url);
      RssFeed rssFeed = RssFeed.parse(utf8.decode(response.bodyBytes));
      rssFeed.items.forEach((element) {
        if (!savedArticles
            .any((savedArticle) => savedArticle.link == element.link)) {
          Article article = Article(
            element.title,
            element.link,
            element.media?.contents != null && element.media.contents.isNotEmpty
                ? element.media.contents[0].url
                : null,
            element.pubDate,
            feed.title,
            feed.url,
          );
          articles.add(article);
        }
      });
    }
    articles.sort((a, b) => b.date.compareTo(a.date));
    articles.insertAll(0, savedArticles);

    notifyListeners();
  }

  Future add(Article article) async {
    savedArticles.add(article);
    await _save();
  }

  Future remove(Article article) async {
    savedArticles.remove(article);
    await _save();
  }

  Future _save() async {
    List<String> encodedArticles = [];
    for (Article article in savedArticles) {
      encodedArticles.add(jsonEncode(article));
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(savedArticlesKey, encodedArticles);
    notifyListeners();
  }

  int length() {
    return articles.length;
  }

  Article getByPosition(int i) {
    return articles[i];
  }

  List<Article> getAll() {
    return articles;
  }
}
