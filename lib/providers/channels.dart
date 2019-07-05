import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import './cache.dart';
import '../model/channel.dart';
import '../ui/views/all-channels.dart';

class Channels {

  List<dynamic> defaultChannels = [
    {
      "name": "כאן 11",
      "key": "CH30",
      "provider": "yes",
      "channelNumber": {
        "hot": 11,
        "yes": 11,
        "partner": 11
      }
    },
    {
      "name": "קשת 12",
      "key": "CH34",
      "provider": "yes",
      "channelNumber": {
        "hot": 12,
        "yes": 12,
        "partner": 12
      }
    },
    {
      "name": "רשת 13",
      "key": "CH36",
      "provider": "yes",
      "channelNumber": {
        "hot": 13,
        "yes": 13,
        "partner": 13
      }
    }
  ];

  static Future<List<ChannelsGroup>> fetchChannelsGroups() async {
    String cacheKey = 'channels-list-2';
    dynamic cache = await Cache.get(cacheKey);
    if (cache != null) {
      return cache.map(((map) => ChannelsGroup.fromJson(map))).toList().cast<ChannelsGroup>();
    } else {
      http.Response request = await http.get('https://ofek.ashery.me/projects/the-channels/channels.json');
      List<dynamic> list = jsonDecode(utf8.decode(request.bodyBytes));
//      Cache.set(cacheKey, list, Duration(days: 4));
      return list.map(((map) => ChannelsGroup.fromJson(map))).toList().cast<ChannelsGroup>();
    }
  }

  static Future<List<Channel>> getFavoriteChannels() async {
    String cacheKey = 'favorite-channels-list';
    dynamic cache = await Cache.get(cacheKey);
    if (cache == null || cache.length == 0) {
      cache = Channels().defaultChannels;
      await Cache.set(cacheKey, cache, null);
    }
    return cache.map(((map) => Channel.fromJson(map))).toList().cast<Channel>();
  }

  static Future<bool> isFavoriteChannels(Channel channel) async {
    String cacheKey = 'favorite-channels-list';
    List<Channel> channels = (await Cache.get(cacheKey) ?? []).map(((map) => Channel.fromJson(map))).toList().cast<Channel>();
    for (Channel listChannel in channels) {
      if (listChannel.provider == channel.provider && listChannel.key == channel.key) {
        return true;
      }
    }
    return false;
  }

  static Future<void> clearFavoriteChannels() async {
    String cacheKey = 'favorite-channels-list';
    await Cache.set(cacheKey, [], null);
  }

  static Future<void> addFavoriteChannels(Channel channel) async {
    String cacheKey = 'favorite-channels-list';
    List<dynamic> cache = await Cache.get(cacheKey) ?? [];
    cache.add(channel.toJson());
    await Cache.set(cacheKey, cache, null);
  }

  static Future<void> removeFavoriteChannels(Channel channel) async {
    String cacheKey = 'favorite-channels-list';
    List<Channel> channels = (await Cache.get(cacheKey) ?? []).map(((map) => Channel.fromJson(map))).toList().cast<Channel>();
    for (int i = 0; i < channels.length; i++) {
      Channel listChannel = channels[i];
      if (listChannel.provider == channel.provider && listChannel.key == channel.key) {
        channels.removeAt(i);
      }
    }
    await Cache.set(cacheKey, channels.map((Channel channel) => channel.toJson()).toList(), null);
  }
}