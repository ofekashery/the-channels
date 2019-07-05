import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../utilities.dart';
import '../model/show.dart';
import '../model/show-details.dart';
import './cache.dart';

class Partner {
  static Future<List<Show>> getShows(String channelId, int days) async {
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day + days);
    String dateString = DateFormat('dd/MM/yyyy').format(date);

    List<dynamic> channels = await Partner().getChannelsData();
    Map<String, dynamic> channel = channels.where((dynamic channel) => channel['id'].toString() == channelId).toList()[0];

    List<dynamic> partnerShows = (channel['events'] as List<dynamic>).where((dynamic show) => show['start'].toString().startsWith(dateString)).toList();
    List<Show> shows = List();
    for (dynamic show in partnerShows) {
      if (Utilities.filterUnnecessaryInformation(shows, show['name'])) {
        shows.add(Show(
          key: show['id'],
          title: show['name'],
          startDate: parseDate(show['start']),
          endDate: parseDate(show['end'])
        ));
      }
    }
    return shows;
  }

  Future<List<dynamic>> getChannelsData() async {
    final String cacheKey = 'partner-channels';
    dynamic cache = await Cache.get(cacheKey);
    if (cache != null) {
      return cache;
    } else {
      String url = 'https://my.partner.co.il/TV.Services/MyTvSrv.svc/SeaChange/GetEpg';
      Map<String, String> headers = {
        'brand': 'orange',
        'category': 'TV',
        'lang': 'he-il',
        'platform': 'WEB',
      };

      http.Response response = await http.post(url, headers: headers);
      if (response.statusCode == 200) {
        dynamic channels = jsonDecode(response.body)['data'];
        Cache.set(cacheKey, channels, Duration(hours: 4));
        return channels;
      } else {
        return [];
      }
    }
  }

  static Future<ShowDetails> getShowDetails(Show show) async {
    final String showId = show.key;
    final String cacheKey = 'partner-show-$showId';
    dynamic cache = await Cache.get(cacheKey);
    Map<String, dynamic> showData;
    if (cache != null) {
      showData = cache;
    } else {
      String url = 'https://my.partner.co.il/TV.Services/MyTvSrv.svc/SeaChange/GetEventTitleBO';
      Map<String, String> headers = {
        'brand': 'orange',
        'category': 'TV',
        'lang': 'he-il',
        'platform': 'WEB',
        'Content-Type': 'application/json;charset=UTF-8'
      };
      String body = '{"_keys":["eventId"],"_values":["$showId"],"eventId":"$showId"}';

      http.Response response = await http.post(url, headers: headers, body: body);
      showData = jsonDecode(response.body)['data'];
      await Cache.set(cacheKey, showData, Duration(days: 1));
    }
    ShowDetails showDetails = ShowDetails(
        title: show.title,
        startDate: show.startDate,
        endDate: show.endDate,
        duration: showData['durationInMinutes'],
        description: showData['shortSynopsis'],
        categories: [],
        posterURL: Partner().getPosterUrl(showData['posterPictureUrl'])
    );
    return showDetails;
  }

  String getPosterUrl(String img) {
    List<String> nonPosters = [
      '/keshet12_logo_p.jpg',
      '/keshet_logo_p.jpg',
      '/ke12_newlogo_p.jpg'
    ];
    if (img == null || nonPosters.contains(img.toLowerCase())) {
      return null;
    }
    return 'http://82.102.167.144/ImagesEPG/$img?w=456&h=256';
  }

  static DateTime parseDate(String date) {
    DateFormat format = new DateFormat('dd/MM/yyyy HH:mm zzz');
    return format.parse(date.split(' ')[0] + ' ' + date.split(' ')[1] + ' GMT+3');
  }
}