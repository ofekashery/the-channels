import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as Dom;
import 'dart:convert';
import 'dart:async';
import '../utilities.dart';
import '../model/show.dart';
import '../model/show-details.dart';
import './cache.dart';

class Yes {
  static Future<List<Show>> getShows(String channelId, int days, { bool allowYesterdayShow = false }) async {
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day + days);
    final String cacheKey = 'yes-$channelId-shows-${date.toIso8601String()}-9';
    dynamic cache = await Cache.get(cacheKey);
    if (cache != null) {
      List<dynamic> list = cache;
      return list.map((dynamic item) => Show.fromJson(item)).toList();
    } else {
      http.Response response = await http.get('https://www.yes.co.il/content/YesChannelsHandler.ashx?action=GetDailyShowsByDayAndChannelCode&dayValue=$days&dayPartByHalfHour=0&channelCode=$channelId');
      Dom.Document document = parse(response.body);

      List<Show> shows = List();
      for (Dom.Element row in document.querySelectorAll('li a')) {
        String title = row.querySelector('span.text').text.split(' - ').sublist(1).join(' - ');
        String time = row.querySelector('span.text').text.split(' - ')[0];
        int hour = int.parse(time.split(':')[0]);
        int minute = int.parse(time.split(':')[1]);
        DateTime startDate = DateTime(now.year, now.month, now.day + days, hour, minute);
        if (Utilities.filterUnnecessaryInformation(shows, title)) {
          shows.add(Show(
            key: row.attributes['schedule_item_id'],
            title: title,
            startDate: startDate,
            endDate: null
          ));
        }
      }

      if (shows.length > 2) {
        DateTime first = shows.elementAt(0).startDate;
        DateTime second = shows.elementAt(1).startDate;
        if (first.isAfter(second)) {
          shows = shows.sublist(1);
        } else if (first.isAfter(second)) {
          Show show = shows.first;
          show.startDate = show.startDate.subtract(Duration(days: 1));
          shows = [show, ...shows.sublist(1)];
        }
      }


      await Cache.set(cacheKey, shows.map((Show show) => show.toJson()).toList(), Duration(hours: 4));
      return shows;
    }
  }

  static Future<ShowDetails> getShowDetails(Show show) async {
    String showId = show.key;
    final String cacheKey = 'yes-show-$showId';
    dynamic cache = await Cache.get(cacheKey);
    if (cache != null) {
      return ShowDetails.fromJson(cache);
    } else {
      http.Response response = await http.get('https://www.yes.co.il/content/YesChannelsHandler.ashx?action=GetProgramDataByScheduleItemID&ScheduleItemID=$showId');
      dynamic showData = jsonDecode(response.body);
      DateTime start = parseDate(showData['Start_Time_Fix_DateTime']);
      DateTime end = parseDate(showData['End_Time_Fix_DateTime']);
      ShowDetails showDetails = ShowDetails(
        title: showData['Hebrew_Name'],
        startDate: start,
        endDate: end,
        duration: start.difference(end).inMinutes,
        description: showData['PreviewText'],
        categories: show != null ? show.categories : []
      );
      await Cache.set(cacheKey, showDetails.toJson(), Duration(days: 1));
      return showDetails;
    }
  }

  String getShowsUrl(String channelId, String date, int pageSize) {
    return 'http://www.hot.net.il/PageHandlers/LineUpAdvanceSearch.aspx?text=&channel=$channelId&genre=-1&ageRating=-1&publishYear=-1&productionCountry=-1&startDate=$date&endDate=$date&startTime=00:00&endTime=23:59&pageSize=$pageSize&isOrderByDate=true&lcid=1037&pageIndex=1';
  }

  static DateTime parseDate(String date) {
    return DateTime.fromMillisecondsSinceEpoch(int.parse(date.replaceAll(RegExp(r'\D+'), '')));
  }
}