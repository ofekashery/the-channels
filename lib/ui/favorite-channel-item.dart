import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../model/show.dart';
import '../model/channel.dart';
import './views/channel.dart';
import './views/show.dart';

class FavoriteChannelItem extends StatelessWidget {
  FavoriteChannelItem(this.channel);

  final Channel channel;
  List<Show> cache;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: channel.getShows(0, allowYesterdayShow: true),
      initialData: cache,
      builder: (BuildContext context, AsyncSnapshot<List<Show>> snapshot) {
        String showText = '';
        Show show;
        if (snapshot.data != null && !snapshot.hasError) {
          cache = snapshot.data;
          DateTime now = DateTime.now();
          for (Show loopShow in snapshot.data) {
            if (loopShow.startDate.isAfter(now)) {
              break;
            }
            showText = loopShow.getStartTime() + ' | ' + loopShow.title;
            show = loopShow;
          }
          if (showText == '') {
            showText = 'אין מידע';
          }
        } else if (snapshot.hasError) {
          showText = 'אין מידע';
        } else {
          showText = 'טוען...';
        }
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (c) {
                    return ChannelPage(channel);
                  }
                )
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: CachedNetworkImage(
                imageUrl: channel.logoUrl,
                fadeOutDuration: Duration(milliseconds: 0),
                placeholder: (BuildContext context, String url) => Container(
                  color: Color(0x0D000000),
                  width: 65,
                  height: 65
                )
              )
            )
          ),
          onTap: show != null && !show.title.contains("נשוב לשדר") && !show.title.contains("שידורינו יתחדשו") ? () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (c) {
                  return ShowPage(show, channel, null);
                }
              )
            );
          } : null,
          title: Text(
            channel.name,
            style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(showText, style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? Colors.black54 : Colors.white70)),
        );
      }
    );
  }
}