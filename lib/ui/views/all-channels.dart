import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import '../../providers/channels.dart';
import '../../model/channel.dart';
import '../channel-item.dart';

class AllChannelsPage extends StatelessWidget {

  List<ChannelsGroup> channels;
  List<String> supportedProviders = ['partner', 'hot', 'yes'];
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.all(Radius.circular(12))
              ),
            ),
          ],
        ),

        SizedBox(height: 19),

        FutureBuilder<List<ChannelsGroup>>(
          future: Channels.fetchChannelsGroups(),
          builder: (BuildContext context, AsyncSnapshot<List<ChannelsGroup>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Expanded(
                  child: Center(
                    child: CircularProgressIndicator()
                  )
                );
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Expanded(
                    child: Center(
                      child: Text('שגיאה', style: Theme.of(context).textTheme.title)
                    )
                  );
                } else if (snapshot.data.length == 0) {
                  return Expanded(
                    child: Center(
                      child: Text('אין מידע', style: Theme.of(context).textTheme.title)
                    )
                  );
                }
                channels = snapshot.data;
                return Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: getPage(context),
                  )
                );
            }
            return null; // unreachable
          },
        )
      ]
    );
  }

  Widget getPage(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 16),
      shrinkWrap: true,
      itemCount: channels.length,
      itemBuilder: (context, index) {
        ChannelsGroup group = channels[index];
        List<Widget> rows = [];
        for (List<Channel> row in group.getRows()) {
          row = row.where((Channel channel) => supportedProviders.contains(channel.provider)).toList();
          rows.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: row.map((Channel channel) => ChannelItem(channel)).toList()
          ));
          rows.add(SizedBox(height: 16));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 16, right: 16, bottom: 8),
                    child: Text(group.name, style: Theme.of(context).textTheme.title),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: rows,
                    ),
                  )
                ]
              )
            ),
            if (index == 3 || index == 7)
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: AdmobBanner(
                adUnitId: 'ca-app-pub-3335065154506773/2878987000',
                adSize: AdmobBannerSize.LARGE_BANNER,
              )
            )
          ],
        );
      }
    );
  }
}

class ChannelsGroup {
  String name;
  int itemsInRow;
  List<Channel> channels;

  ChannelsGroup({this.name, this.channels});

  ChannelsGroup.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    itemsInRow = json['itemsInRow'] ?? (json['channels'] ?? []).length;
    channels = (json['channels'] ?? []).map((dynamic channel) => Channel.fromJson(channel)).toList().cast<Channel>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['itemsInRow'] = this.itemsInRow ?? 0;
    data['channels'] = (this.channels ?? []).map((Channel channel) => channel.toJson()).toList();
    return data;
  }

  List<List<Channel>> getRows() {
    if (itemsInRow <= 0) {
      return [];
    } else if (itemsInRow >= channels.length) {
      return [channels];
    }


    List<List<Channel>> chunks = [];
    for (var i = 0; i < channels.length; i += itemsInRow) {
      if (i + itemsInRow >= channels.length) {
        chunks.add(channels.sublist(i, channels.length));
      } else {
        chunks.add(channels.sublist(i, i + itemsInRow));
      }
    }
    return chunks;
  }
}
