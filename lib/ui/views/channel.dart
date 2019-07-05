import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as Intl;
import 'package:async/async.dart';
import '../show-item.dart';
import './../favorite-channel-button.dart';
import './show.dart';
import '../../model/channel.dart';
import '../../model/show.dart';

class ChannelPage extends StatefulWidget {
  ChannelPage(this.channel);

  final Channel channel;

  @override
  ChannelPageState createState() => ChannelPageState();
}

class ChannelPageState extends State<ChannelPage> {

  final List<Day> days = List<Day>.generate(7, (i) => Day(i));
  PanelController panelController = PanelController();
  final GlobalKey currentShowKey = GlobalKey();
  Show selectedShow;

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics().logEvent(name: 'channel_opened',
      parameters: <String, dynamic>{
        'channel_name': widget.channel.name,
        'channel_provider': widget.channel.provider
      }
    );
    return Material(
      child: SlidingUpPanel(
        backdropEnabled: true,
        panel: Container(
          child: selectedShow != null ? ShowPage(selectedShow, widget.channel, panelController) : Center(
            child: Text('שגיאה', style: Theme.of(context).textTheme.title),
          )
        ),
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height,
        controller: panelController,
        body: DefaultTabController(
          length: days.length + 1,
          initialIndex: 1,
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.channel.name),
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'מידע'),
                  ...days.map((Day day) => day.getTab()).toList()
                ],
              ),
              actions: <Widget>[FavoriteChannelButton(widget.channel)],
            ),
            body: Container(
              child: TabBarView(
                children: [
                  getInfoView(widget.channel),
                  ...days.map((Day day) => getDayView(day)).toList()
                ]
              )
            )
          )
        ),
      )
    );
  }

  List<Tab> getTabs(int count) {
    List<Tab> tabs = [];
    for (int i = 0; i < count; i++) {
      if (i == 0) {
        tabs.add(Tab(text: 'היום'));
      } else if (i == 1) {
        tabs.add(Tab(text: 'מחר'));
      } else {
        DateTime date = DateTime.now().add(Duration(days: i));
        tabs.add(Tab(text: Intl.DateFormat('EEEE').format(date)));
      }
    }
    return tabs;
  }

  Widget getInfoView(Channel channel) {
    return ListView(
      padding: EdgeInsets.all(10),
      children: <Widget>[
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 24, 16),
              child: Text('צפייה', style: Theme.of(context).textTheme.title, textAlign: TextAlign.start),
            ),
            if (channel.channelNumber != null && channel.channelNumber.hot != null)
              ListTile(
                leading: Container(
                  height: 24,
                  width: 24,
                  child: Image.asset('assets/hot.png'),
                ),
                title: Text('משודר בערוץ ${channel.channelNumber.hot} בהוט')
              ),
              if (channel.channelNumber != null && channel.channelNumber.yes != null)
              ListTile(
                leading: Container(
                  height: 24,
                  width: 24,
                  child: Image.asset('assets/yes.png'),
                ),
                title: Text('משודר בערוץ ${channel.channelNumber.yes} ביס')
              ),
              if (channel.channelNumber != null && channel.channelNumber.partner != null)
              ListTile(
                leading: Container(
                  height: 24,
                  width: 24,
                  child: Image.asset('assets/partnertv.png'),
                ),
                title: Text('משודר בערוץ ${channel.channelNumber.partner} בפרטנר TV')
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 20),
          child: AdmobBanner(
            adUnitId: 'ca-app-pub-3335065154506773/2878987000',
            adSize: AdmobBannerSize.MEDIUM_RECTANGLE,
          )
        )
      ]
    );
  }

  Widget getPanel(Widget body) {
    BorderRadiusGeometry panelRadius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    return Material(
      child: SlidingUpPanel(
        backdropEnabled: true,
        borderRadius: panelRadius,
        panel: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: panelRadius
          ),
          child: Container()
        ),
        minHeight: 100,
        maxHeight: MediaQuery.of(context).size.height * 8 / 10,
        controller: panelController,
        body: body,
      ),
    );
  }

  Widget getDayView(Day day) {
    return FutureBuilder<List<Show>>(
      future: fetchData(day),
      builder: (BuildContext context, AsyncSnapshot<List<Show>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator()
            );
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Center(
                  child: Text('שגיאה', style: Theme.of(context).textTheme.title)
              );
            } else if (snapshot.data.length == 0) {
              return Center(
                child: Text('אין מידע', style: Theme.of(context).textTheme.title)
              );
            }
            Show currentShow;
            if (day.index == 0) {
              DateTime now = DateTime.now();
              for (Show loopShow in snapshot.data) {
                if (loopShow.startDate.isAfter(now)) {
                  break;
                }
                currentShow = loopShow;
              }
            }
            List<Widget> widgets = List();
            for (Show loopShow in snapshot.data) {
              widgets.add(ShowItem(
                show: loopShow,
                onTap: () {
                  setState(() {
                    selectedShow = loopShow;
                  });
                  panelController.open();
                },
                isCurrently: currentShow == loopShow,
                key: currentShow == loopShow ? currentShowKey : null
              ));

              if (loopShow != snapshot.data.last) {
                widgets.add(Divider(
                  height: 1,
                  color: Theme.of(context).brightness == Brightness.light ? Colors.black12 : Colors.white12,
                ));
              }
            }

            if (day.index == 0) {
              Future.delayed(Duration(milliseconds: 10), () {
                if (currentShowKey.currentWidget != null) {
                  Scrollable.ensureVisible(currentShowKey.currentContext);
                }
              });
            }

            return SingleChildScrollView(
              child: Column(
                children: widgets,
              )
            );
        }
        return null; // unreachable
      },
    );
  }

  Future<List<Show>> fetchData(Day day) {
    return day.memoizer.runOnce(() async {
      return await widget.channel.getShows(day.index);
    });
  }
}

class Day {
  Day(this.index);

  final int index;
  final AsyncMemoizer<List<Show>> memoizer = AsyncMemoizer();

  Tab getTab() {
    if (index == 0) {
      return Tab(text: 'היום');
    } else if (index == 1) {
      return Tab(text: 'מחר');
    } else {
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day + index);
      return Tab(text: Intl.DateFormat('EEEE').format(date));
    }
  }
}