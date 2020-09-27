class FeedSearchEntry {
  String feedId;
  String title;
  String visualUrl;

  FeedSearchEntry.fromJson(Map<String, dynamic> json)
      : feedId = json['feedId'],
        title = json['title'],
        visualUrl = json['visualUrl'];
}
