import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

import 'package:rssreader/models/feed.dart';

class FeedPage extends StatefulWidget {
  @override
  FeedPageState createState() {
    return FeedPageState();
  }
}

class FeedPageState extends State<FeedPage> {
  final TextEditingController feedUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Feed"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              http.Response response = await http.get(feedUrlController.text);
              RssFeed rssFeed = RssFeed.parse(utf8.decode(response.bodyBytes));
              Navigator.pop(context, Feed(feedUrlController.text, rssFeed.title));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.rss_feed),
            title: TextField(
              decoration: InputDecoration(
                hintText: "RSS Feed URL",
              ),
              controller: feedUrlController,
              autocorrect: false,
            )
          )
        ],
      )
    );
  }
}