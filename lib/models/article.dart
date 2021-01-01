import 'package:intl/intl.dart';

class Article {
  String title;
  String link;
  String imageUrl;
  DateTime date; // local time
  String feedTitle;
  String feedUrl;
  bool isSaved = false;

  Article(String title, String link, String imageUrl, String date,
      String feedTitle, String feedUrl) {
    this.title = title;
    this.link = link;
    this.imageUrl = imageUrl;
    this.feedTitle = feedTitle;
    this.feedUrl = feedUrl;

    DateFormat dateFormat = new DateFormat("EEE, dd MMM yyyy HH:mm:ss");
    this.date = dateFormat.parseUTC(date);

    String tzOffset = date.substring(date.length - 5);
    RegExpMatch match = RegExp(r'([+-])(\d{2})(\d{2})').firstMatch(tzOffset);

    if (match.groupCount == 3) {
      Duration duration = Duration(
        hours: int.parse(match.group(2)),
        minutes: int.parse(match.group(3)),
      );
      if (match.group(1) == "-") {
        this.date = this.date.add(duration);
      } else {
        this.date = this.date.subtract(duration);
      }
    }
  }

  String getDateDurationString() {
    Duration duration = DateTime.now().difference(date);
    if (duration >= Duration(days: 1)) {
      return duration.inDays.toString() + "d";
    } else if (duration >= Duration(hours: 1)) {
      return duration.inHours.toString() + "h";
    } else if (duration >= Duration(minutes: 1)) {
      return duration.inMinutes.toString() + "m";
    } else {
      return duration.inSeconds.toString() + "s";
    }
  }

  Article.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        link = json['link'],
        imageUrl = json['image_url'],
        date = DateTime.parse(json['date']),
        feedTitle = json['feed_title'],
        feedUrl = json['feed_url'],
        isSaved = true;

  Map<String, dynamic> toJson() => {
        'title': title,
        'link': link,
        'image_url': imageUrl,
        'date': date.toString(),
        'feed_title': feedTitle,
        'feed_url': feedUrl,
      };
}
