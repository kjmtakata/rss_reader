import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rssreader/models/feed_search_entry.dart';
import 'package:webfeed/webfeed.dart';

import 'package:rssreader/models/feed.dart';
import 'package:rssreader/models/feed_search_response.dart';
import 'package:rssreader/models/feeds.dart';

enum FeedAction { delete }

class FeedsPage extends StatefulWidget {
  @override
  FeedsPageState createState() {
    return FeedsPageState();
  }
}

class FeedsPageState extends State<FeedsPage> {
  List<Feed> feeds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feeds'),
      ),
      body: ListView.builder(
        itemBuilder: (context, i) {
          Feeds feeds = Provider.of<Feeds>(context);
          if (i < feeds.length()) {
            Feed feed = feeds.getByPosition(i);
            return ListTile(
              title: Text(feed.title),
              trailing: PopupMenuButton(
                itemBuilder: (_) => <PopupMenuItem<FeedAction>>[
                  new PopupMenuItem<FeedAction>(
                    child: const Text('Delete'),
                    value: FeedAction.delete,
                  ),
                ],
                onSelected: (action) {
                  if (action == FeedAction.delete) {
                    feeds.remove(feed);
                  }
                },
              ),
            );
          } else {
            return null;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Feed result =
              await showSearch(context: context, delegate: FeedsSearch());

          if (result != null) {
            Provider.of<Feeds>(context, listen: false).add(result);
          }
        },
        tooltip: 'Add RSS Feed',
        child: Icon(Icons.add),
      ),
    );
  }
}

class FeedsSearch extends SearchDelegate<Feed> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length > 0) {
      Uri uri =
          Uri.https("cloud.feedly.com", "/v3/search/feeds", {"query": query});
      return FutureBuilder(
        future: http.get(uri),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            http.Response response = snapshot.data;
            FeedSearchResponse feedSearchResponse =
                FeedSearchResponse.fromJson(jsonDecode(response.body));
            return ListView.builder(
              itemCount: feedSearchResponse.results.length,
              itemBuilder: (context, i) {
                FeedSearchEntry feedSearchEntry = feedSearchResponse.results[i];
                return ListTile(
                  title: Text(feedSearchEntry.title),
                  leading: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/transparent.png',
                    image: feedSearchEntry.visualUrl,
                    width: 30,
                    height: 30,
                  ),
                  onTap: () async {
                    String errorMessage;
                    try {
                      String feedUrl = feedSearchEntry.feedId.substring(5);
                      http.Response response = await http.get(feedUrl);
                      RssFeed rssFeed =
                          RssFeed.parse(utf8.decode(response.bodyBytes));
                      Navigator.pop(context, Feed(feedUrl, rssFeed.title));
                    } on ArgumentError catch (e) {
                      errorMessage = e.message;
                    } on SocketException catch (e) {
                      errorMessage = e.message;
                    } on FormatException catch (_) {
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
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
    } else {
      return Column();
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
