class Feed {
  String url;
  String title;

  Feed(this.url, this.title);

  Feed.fromJson(Map<String, dynamic> json)
    : url = json['url'],
      title = json['title'];

  Map<String, dynamic> toJson() =>
  {
    'url': url,
    'title': title,
  };
}