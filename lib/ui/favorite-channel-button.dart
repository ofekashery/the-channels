import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import '../providers/channels.dart';
import '../model/channel.dart';

class FavoriteChannelButton extends StatefulWidget {

  FavoriteChannelButton(this.channel);
  final Channel channel;

  @override
  FavoriteChannelButtonState createState() => FavoriteChannelButtonState();
}

class FavoriteChannelButtonState extends State<FavoriteChannelButton> {

  bool oldValue;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Channels.isFavoriteChannels(widget.channel),
      initialData: oldValue,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.data != null) {
          oldValue = snapshot.data;
          if (snapshot.data) {
            FirebaseAnalytics().logEvent(name: 'remove_favorite_channel',
              parameters: <String, dynamic>{
                'channel_name': widget.channel.name,
                'channel_provider': widget.channel.provider
              }
            );
            return IconButton(
              icon: Icon(MdiIcons.star),
              onPressed: () async {
                await Channels.removeFavoriteChannels(widget.channel);
                setState(() {});
              }
            );
          } else {
            FirebaseAnalytics().logEvent(name: 'add_favorite_channel',
              parameters: <String, dynamic>{
                'channel_name': widget.channel.name,
                'channel_provider': widget.channel.provider
              }
            );
            return IconButton(
              icon: Icon(MdiIcons.starOutline),
              onPressed: () async {
                await Channels.addFavoriteChannels(widget.channel);
                setState(() {});
              }
            );
          }
        }
        return Container();
      }
    );
  }
}