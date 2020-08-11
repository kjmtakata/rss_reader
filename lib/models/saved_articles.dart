import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rssreader/models/article.dart';

class SavedArticles extends ChangeNotifier {
  static final String savedArticlesKey = "saved_articles";
  List<Article> articles = [];

  Future load() async {
    articles.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (!prefs.containsKey(savedArticlesKey)) {
      await prefs.setStringList(savedArticlesKey, []);
    }
    for (String feedJson in prefs.getStringList(savedArticlesKey)) {
      articles.add(Article.fromJson(jsonDecode(feedJson)));
    }
    notifyListeners();
  }

  Future add(Article article) async {
    articles.add(article);
    await save();
  }

  Future remove(Article article) async {
    articles.remove(article);
    await save();
  }

  Future save() async {
    List<String> encodedArticles = [];
    for (Article article in articles) {
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