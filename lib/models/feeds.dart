import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rssreader/models/feed.dart';

class Feeds extends ChangeNotifier {
  static final String feedsKey = "feeds";
  List<Feed> feeds = [];

  Future load() async {
    feeds.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (!prefs.containsKey(feedsKey)) {
      await prefs.setStringList(feedsKey, []);
    }
    for (String feedJson in prefs.getStringList(feedsKey)) {
      feeds.add(Feed.fromJson(jsonDecode(feedJson)));
    }
    notifyListeners();
  }

  Future add(Feed feed) async {
    feeds.add(feed);
    await save();
  }

  Future remove(Feed feed) async {
    feeds.remove(feed);
    await save();
  }

  Future save() async {
    List<String> encodedFeeds = [];
    for (Feed feed in feeds) {
      encodedFeeds.add(jsonEncode(feed));
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(feedsKey, encodedFeeds);
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
