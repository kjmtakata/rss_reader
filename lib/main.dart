import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:rssreader/models/feeds.dart';
import 'package:rssreader/screens/articles.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Feeds(),
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return MaterialApp(
      title: 'RSS Reader',
      home: ArticlesPage(),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.black,
      ),
    );
  }
}