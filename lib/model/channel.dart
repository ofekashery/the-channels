import '../providers/partner.dart';
import '../providers/hot.dart';
import '../providers/yes.dart';
import './show.dart';
import './show-details.dart';

class Channel {

  Channel(this.key, this.name, this.provider, this.channelNumber, this.logoUrl);

  String key;
  String name;
  String provider;
  ChannelNumber channelNumber;
  String logoUrl;

  Future<List<Show>> getShows(int days, { bool allowYesterdayShow = false }) {
    if (provider == 'partner') {
      return Partner.getShows(key, days);
    } else if (provider == 'hot') {
      return Hot.getShows(key, days);
    } else if (provider == 'yes') {
      return Yes.getShows(key, days, allowYesterdayShow: allowYesterdayShow);
    }
    return null;
  }

  Future<ShowDetails> getShowDetails(Show show) {
    if (provider == 'partner') {
      return Partner.getShowDetails(show);
    } else if (provider == 'hot') {
      return Hot.getShowDetails(show);
    } else if (provider == 'yes') {
      return Yes.getShowDetails(show);
    }
    return null;
  }

  Channel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    key = json['key'];
    provider = json['provider'] ?? 'partner';
    channelNumber = ChannelNumber.fromJson(json['channelNumber'] ?? {});
    logoUrl = 'https://ofek.ashery.me/projects/the-channels/${provider.substring(0, 1)}$key.jpg';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['key'] = this.key;
    data['provider'] = this.provider;
    if (this.channelNumber != null) {
      data['channelNumber'] = this.channelNumber.toJson();
    }
    data['logoUrl'] = this.logoUrl;
    return data;
  }
}

class ChannelNumber {
  int hot;
  int yes;
  int partner;

  ChannelNumber({this.hot, this.yes, this.partner});

  ChannelNumber.fromJson(Map<String, dynamic> json) {
    hot = json['hot'];
    yes = json['yes'];
    partner = json['partner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hot'] = this.hot;
    data['yes'] = this.yes;
    data['partner'] = this.partner;
    return data;
  }
}
