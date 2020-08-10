import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rssreader/models/feed.dart';

class Feeds extends ChangeNotifier {
  List<Feed> feeds = [];

  Future load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    feeds.clear();
    await prefs.reload();
    for (String feedUrl in prefs.getKeys()) {
      String feedTitle = prefs.getString(feedUrl);
      feeds.add(Feed(feedUrl, feedTitle));
    }
    notifyListeners();
  }

  Future add(Feed feed) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(feed.url, feed.title);
    feeds.add(feed);
    notifyListeners();
  }

  Future remove(Feed feed) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(feed.url);
    feeds.remove(feed);
    notifyListeners();
  }

  int length() {
    return feeds.length;
  }

  Feed getByPosition(int i) {
    return feeds[i];
  }

  List<Feed> getAll() {
    return feeds;
  }
}