import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:rssreader/models/article.dart';
import 'package:rssreader/models/articles.dart';
import 'package:rssreader/models/feed.dart';
import 'package:rssreader/screens/article.dart';
import 'package:rssreader/screens/feeds.dart';

class ArticlesListView extends StatelessWidget {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  final String filter;
  final String feedUrl;

  ArticlesListView(this.filter, this.feedUrl);

  @override
  Widget build(BuildContext context) {
    Articles articlesProvider = Provider.of<Articles>(context);
    List<Article> articles = articlesProvider.articles;
    articles = articles
        .where((article) =>
            article.title.toLowerCase().contains(filter.toLowerCase()))
        .toList();

    if (this.feedUrl != null) {
      articles =
          articles.where((article) => article.feedUrl == this.feedUrl).toList();
    }

    return SmartRefresher(
      enablePullDown: true,
      controller: _refreshController,
      onRefresh: () async {
        await Provider.of<Articles>(context, listen: false).load(context);
        _refreshController.refreshCompleted();
      },
      child: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, i) {
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

          List<Widget> trailingWidgets = [
            Text(article.getDateDurationString()),
          ];
          if (article.isSaved) {
            trailingWidgets.add(Icon(Icons.favorite));
          }

          return ListTile(
            leading: image,
            title: Text(article.title),
            subtitle: Text(article.feedTitle),
            trailing: Wrap(
              direction: Axis.vertical,
              spacing: 5,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: trailingWidgets,
            ),
            selected: article.isSaved,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ArticlePage(article)),
              );
            },
            onLongPress: () {
              article.isSaved = !article.isSaved;
              if (article.isSaved) {
                articlesProvider.add(article);
              } else {
                articlesProvider.remove(article);
              }
            },
          );
        },
      ),
    );
  }
}

class ArticlesSearch extends SearchDelegate {
  final String feedUrl;

  ArticlesSearch(this.feedUrl);

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
    return ArticlesListView(query, this.feedUrl);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}

class ArticlesPage extends StatefulWidget {
  final Feed feed;

  ArticlesPage(this.feed);

  @override
  ArticlesPageState createState() {
    return ArticlesPageState(feed);
  }
}

class ArticlesPageState extends State<ArticlesPage> {
  final Feed feed;

  ArticlesPageState(this.feed);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.feed != null ? feed.title : "Articles"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context, delegate: ArticlesSearch(this.feed?.url));
            },
          )
        ],
      ),
      drawer: this.feed == null
          ? Drawer(
              child: FeedsPage(),
            )
          : null,
      body: ArticlesListView("", this.feed?.url),
    );
  }
}
