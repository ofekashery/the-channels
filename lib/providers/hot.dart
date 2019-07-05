import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as Dom;
import 'package:intl/intl.dart';
import 'dart:async';
import '../utilities.dart';
import '../model/show.dart';
import '../model/show-details.dart';
import './cache.dart';

class Hot {
  static Future<List<Show>> getShows(String channelId, int days) async {
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day + days);
    final String cacheKey = 'hot-$channelId-shows-${date.toIso8601String()}';
    String dateString = DateFormat('dd/MM/yyyy').format(date);
    dynamic cache = await Cache.get(cacheKey);
    if (cache != null) {
      List<dynamic> list = cache;
      return list.map((dynamic item) => Show.fromJson(item)).toList();
    } else {
      http.Response checkSize = await http.get(Hot().getShowsUrl(channelId, dateString, 1));

      int size = 0;
      try {
        size = int.parse(parse(checkSize.body).querySelector('.widgetHPTitle h2').text.replaceAll(RegExp(r'\D+'), ''));
      } catch (e) {
        return [];
      }

      http.Response response = await http.get(Hot().getShowsUrl(channelId, dateString, size));
      Dom.Document document = parse(response.body);

      List<Show> shows = List();
      for (Dom.Element row in document.querySelectorAll('tr.redtr_off')) {
        String title = row.children[2].text.trim();
        int durationHours = int.parse(row.children[5].text.split(':')[0]);
        int durationMinutes = int.parse(row.children[5].text.split(':')[1]);
        DateTime startDate = parseDate(row.children[4].text.split(', ')[1].trim());
        DateTime endDate = DateTime(startDate.year, startDate.month, startDate.day, startDate.hour + durationHours, startDate.minute + durationMinutes);

        if (Utilities.filterUnnecessaryInformation(shows, title)) {
          shows.add(Show(
            key: row.attributes['onclick'].split('=')[2].replaceAll(RegExp(r'\D+'), ''),
            title: title,
            startDate: startDate,
            endDate: endDate,
            categories: [Hot().getCategories(row.children[3].text.trim())].where((String str) => str != null && str.isNotEmpty).toList().cast<String>()
          ));
        }
      }

      await Cache.set(cacheKey, shows.map((Show show) => show.toJson()).toList(), Duration(hours: 4));
      return shows;
    }
  }

  static Future<ShowDetails> getShowDetails(Show show) async {
    final String showId = show.key;
    final String cacheKey = 'hot-show-$showId';
    dynamic cache = await Cache.get(cacheKey);
    if (cache != null) {
      return ShowDetails.fromJson(cache);
    } else {
      http.Response response = await http.get('https://www.hot.net.il/PageHandlers//LineUpDetails.aspx?lcid=1037&luid=$showId');
      Dom.Document document = parse(response.body);

      String contentRating;
      if (document.querySelectorAll('.LineUpbold').length > 1 && document.querySelectorAll('.LineUpbold')[1].text.trim() != 'ללא הגבלת צפייה') {
        String limit = document.querySelectorAll('.LineUpbold')[1].text.trim();
        if (limit.startsWith('מתאים לצפייה מגיל ')) {
          contentRating = limit.replaceAll(RegExp(r'\D+'), '') + '+';
        } else if (limit == 'XXX - נועז') {
          contentRating = '18+';
        }
      }

      ShowDetails showDetails = ShowDetails(
        title: show.title,
        startDate: show.startDate,
        endDate: show.endDate,
        duration: show.startDate.difference(show.endDate).inMinutes,
        description: document.querySelector('div.show').text.trim(),
        categories: show.categories,
        contentRating: contentRating
      );
      await Cache.set(cacheKey, showDetails.toJson(), Duration(days: 1));
      return showDetails;
    }
  }

  String getCategories(String genres) {
    switch (genres) {
      case 'תרבות בידור ומוסיקה':
        return 'בידור';
      case 'תעודה טבע ופנאי':
        return 'טבע ותעודה';
      default:
        return genres;
    }
  }
  String getShowsUrl(String channelId, String date, int pageSize) {
    return 'http://www.hot.net.il/PageHandlers/LineUpAdvanceSearch.aspx?text=&channel=$channelId&genre=-1&ageRating=-1&publishYear=-1&productionCountry=-1&startDate=$date&endDate=$date&startTime=00:00&endTime=23:59&pageSize=$pageSize&isOrderByDate=true&lcid=1037&pageIndex=1';
  }

  static DateTime parseDate(String date) {
    DateFormat format = new DateFormat('dd/MM/yyyy HH:mm zzz');
    return format.parse(date.split(' ')[0] + ' ' + date.split(' ')[1] + ' GMT+3');
  }
}