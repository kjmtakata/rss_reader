import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:webfeed/webfeed.dart';

import 'package:rssreader/models/article.dart';
import 'package:rssreader/models/feed.dart';
import 'package:rssreader/models/feeds.dart';
import 'package:rssreader/screens/article.dart';
import 'package:rssreader/screens/feeds.dart';

class ArticlesPage extends StatefulWidget {
  @override
  ArticlesPageState createState() {
    return ArticlesPageState();
  }
}

class ArticlesPageState extends State<ArticlesPage> {
  List<Article> articles = [];
  RefreshController _refreshController =
    RefreshController(initialRefresh: true);

  void _onRefresh() async {
    Feeds feedsProvider = Provider.of<Feeds>(context, listen: false);
    await feedsProvider.load();
    articles.clear();
    for (Feed feed in feedsProvider.getAll()) {
      print("refreshing feed: " + feed.url);
      http.Response response = await http.get(feed.url);
      RssFeed rssFeed = RssFeed.parse(utf8.decode(response.bodyBytes));
      rssFeed.items.forEach((element) {
        Article article = Article(
          element.title,
          element.link,
          element.media?.contents != null && element.media.contents.isNotEmpty ?
            element.media.contents[0].url : null,
          element.pubDate,
          feed,
        );
        articles.add(article);
      });
    }
    setState(() {
      articles.sort((a, b) => b.date.compareTo(a.date));
    });
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Articles'),
      ),
      drawer: Drawer(
        child: FeedsPage(),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: ListView.builder(
          itemBuilder: (context, i) {
            if (i < articles.length) {
              Article article = articles[i];
              Widget image;
              if (article.imageUrl != null) {
                image = FadeInImage.assetNetwork(
                  placeholder: 'assets/images/transparent.png',
                  image: article.imageUrl,
                  width: 60,
                  height: 60,
                );
              }

              return ListTile(
                leading: image,
                title: Text(article.title),
                subtitle: Text(article.feed.title),
                trailing: Text(article.getDateDurationString()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        ArticlePage(article.link, article.title)
                    ),
                  );
                },
              );
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }
}