import 'package:rssreader/models/feed_search_entry.dart';

class FeedSearchResponse {
  List<FeedSearchEntry> results;

  FeedSearchResponse.fromJson(Map<String, dynamic> json) {
    results = [];
    var resultsList = json['results'];
    resultsList.forEach((result) {
      results.add(FeedSearchEntry.fromJson(result));
    });
  }
}
