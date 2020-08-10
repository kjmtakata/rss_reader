import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rssreader/models/feed.dart';
import 'package:rssreader/models/feeds.dart';
import 'package:rssreader/screens/feed.dart';

enum FeedAction {
  delete
}

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
          Feed result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FeedPage()),
          );

          Provider.of<Feeds>(context, listen: false).add(result);
        },
        tooltip: 'Add RSS Feed',
        child: Icon(Icons.add),
      ),
    );
  }
}