import 'dart:convert';
import 'dart:io';

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
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  String errorMessage;
                  try {
                    http.Response response = await http.get(feedUrlController.text);
                    RssFeed rssFeed = RssFeed.parse(utf8.decode(response.bodyBytes));
                    Navigator.pop(context, Feed(feedUrlController.text, rssFeed.title));
                  } on ArgumentError catch (e) {
                    errorMessage = e.message;
                  } on SocketException catch (e) {
                    errorMessage = e.message;
                  } on FormatException catch (e) {
                    errorMessage = "Invalid RSS feed";
                  } catch (e) {
                    errorMessage = e.toString();
                  } finally {
                    if (errorMessage != null) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(errorMessage),
                      ));
                    }
                  }
                },
              );
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