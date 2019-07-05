import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../providers/cache.dart';
import '../../providers/channels.dart';
import '../favorite-channel-item.dart';
import '../../model/channel.dart';

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Channels.getFavoriteChannels(),
      builder: (BuildContext context, AsyncSnapshot<List<Channel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (!snapshot.hasError) {
            List<Widget> channelsCards = snapshot.data.map((Channel channel) => Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                clipBehavior: Clip.antiAlias,
                child: FavoriteChannelItem(channel)
              )
            )).toList();
            return ListView(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              children: [
                ...channelsCards,
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: AdmobBanner(
                    adUnitId: 'ca-app-pub-3335065154506773/2878987000',
                    adSize: AdmobBannerSize.BANNER,
                  )
                )
              ],
            );
          } else {
            return Center(
              child: Text('שגיאה', style: Theme.of(context).textTheme.title)
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator()
          );
        }
      }
    );

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 10),
      children: <Widget>[
        SizedBox(
          height: max(40, MediaQuery.of(context).size.height / 2 - 230),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          child: FutureBuilder(
            future: Channels.getFavoriteChannels(),
            builder: (BuildContext context, AsyncSnapshot<List<Channel>> snapshot) {
              List<Widget> widgets = List();
              if (snapshot.connectionState == ConnectionState.done) {
                if (!snapshot.hasError) {
                  List<String> keys = snapshot.data.map((Channel channel) => '${channel.provider}-${channel.key}').toList();
                  Cache.set('last-favorite-channels', keys, null);
                  widgets = snapshot.data.map((Channel channel) => FavoriteChannelItem(channel)).toList();
                } else {
                  widgets = [
                    Padding(
                      padding: EdgeInsets.all(50),
                      child: Center(
                        child: Text('שגיאה', style: Theme.of(context).textTheme.title),
                      ),
                    )
                  ];
                }
              } else {
                widgets = [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 105),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                ];
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 24, 4),
                    child: Text("ערוצים מועדפים", style: Theme.of(context).textTheme.title, textAlign: TextAlign.start),
                  ),
                  ...widgets
                ]
              );
            }
          )
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 15),
          child: AdmobBanner(
//            adUnitId: 'ca-app-pub-3335065154506773/2878987000',
            adUnitId: 'ca-app-pub-3940256099942544/6300978111',
            adSize: AdmobBannerSize.BANNER,
          )
        )
      ]
    );
  }

  @override
  Widget oldBuild(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 10),
      children: <Widget>[
        SizedBox(
          height: max(40, MediaQuery.of(context).size.height / 2 - 230),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          child: FutureBuilder(
            future: Channels.getFavoriteChannels(),
            builder: (BuildContext context, AsyncSnapshot<List<Channel>> snapshot) {
              List<Widget> widgets = List();
              if (snapshot.connectionState == ConnectionState.done) {
                if (!snapshot.hasError) {
                  List<String> keys = snapshot.data.map((Channel channel) => '${channel.provider}-${channel.key}').toList();
                  Cache.set('last-favorite-channels', keys, null);
                  widgets = snapshot.data.map((Channel channel) => FavoriteChannelItem(channel)).toList();
                } else {
                  widgets = [
                    Padding(
                      padding: EdgeInsets.all(50),
                      child: Center(
                        child: Text('שגיאה', style: Theme.of(context).textTheme.title),
                      ),
                    )
                  ];
                }
              } else {
                widgets = [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 105),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                ];
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 24, 4),
                    child: Text("ערוצים מועדפים", style: Theme.of(context).textTheme.title, textAlign: TextAlign.start),
                  ),
                  ...widgets
                ]
              );
            }
          )
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 15),
          child: AdmobBanner(
//            adUnitId: 'ca-app-pub-3335065154506773/2878987000',
            adUnitId: 'ca-app-pub-3940256099942544/6300978111',
            adSize: AdmobBannerSize.BANNER,
          )
        )
      ]
    );
  }
}
