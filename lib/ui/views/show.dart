import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../model/channel.dart';
import '../../model/show.dart';
import '../../model/show-details.dart';

class ShowPage extends StatelessWidget {


  ShowPage(this.show, this.channel, this.panelController, {Key key}) : super(key: key);

  final Show show;
  final Channel channel;
  final PanelController panelController;
  ShowDetails showDetails;

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics().logEvent(name: 'show_opened',
      parameters: <String, dynamic>{
        'show_name': show.title,
        'channel_name': channel.name,
        'channel_provider': channel.provider
      }
    );

    return Material(
      child: FutureBuilder<ShowDetails>(
        future: channel.getShowDetails(show),
        builder: (BuildContext context, AsyncSnapshot<ShowDetails> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator()
              );
            case ConnectionState.done:
              if (snapshot.hasError || snapshot.data == null) {
                return Center(
                    child: Text('אין מידע', style: Theme.of(context).textTheme.title)
                );
              } else {
                showDetails = snapshot.data;
                return Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: getPage(context)
                );
              }
          }
        }
      )
    );
  }

  Widget getPage(BuildContext context) {
    Color textColor = Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white;
    TextStyle textStyle = Theme.of(context).textTheme.body1.copyWith(fontSize: 16, color: textColor);
    return Column(
      children: <Widget>[
        if (showDetails.posterURL != null)
        Container(
          height: 230,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.network(
                showDetails.posterURL,
                fit: BoxFit.cover
              ),
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: () => pop(context),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    child: Icon(MdiIcons.close),
                  )
                )
              )
            ]
          )
        ),
        if (showDetails.posterURL == null)
        Padding(
          padding: EdgeInsets.only(top: 8, bottom: 24),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: showDetails.posterURL == null ? Text(showDetails.title) : null,
            leading: IconButton(
              icon: Icon(MdiIcons.close),
              onPressed: () => pop(context)
            )
          )
        ),
        Expanded(
          child: Container(
            transform: showDetails.posterURL != null ?  Matrix4.translationValues(0, -16, 0) : null,
            decoration: showDetails.posterURL != null ? BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16)
              )
            ) : null,
            child: ScrollConfiguration(
              behavior: HideScrollGlow(),
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: <Widget>[
                  if (showDetails.posterURL != null)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(showDetails.title ,style: TextStyle(fontWeight: FontWeight.w400, fontSize: 22, color: textColor))
                  ),
                  Text(DateFormat('EEEE, dd בMMM, בשעה HH:mm').format(showDetails.startDate)
                    + ' עד ' + DateFormat('HH:mm').format(showDetails.endDate), style: textStyle),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(showDetails.getDescription(), style: textStyle.copyWith(color: textColor.withAlpha(160)))
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      direction: Axis.horizontal,
                      children: showDetails.getCategoriesChips(context),
                    )
                  )
                ],
              )
            )
          )
        ),
        Container(
          margin: EdgeInsets.only(bottom: 20),
          child: RegisterButton(show, channel, showDetails)
        )
      ],
    );
  }


  pop(BuildContext context) {
    if (panelController != null) {
      panelController.close();
    } else {
      Navigator.of(context).pop();
    }
  }
}

class RegisterButton extends StatefulWidget {

  @override
  RegisterButtonState createState() => RegisterButtonState();

  RegisterButton(this.show, this.channel, this.showDetails, {Key key}) : super(key: key);

  final Show show;
  final Channel channel;
  final ShowDetails showDetails;

}

class RegisterButtonState extends State<RegisterButton> {

  PendingNotificationRequest reminder;
  bool loaded = false;

  loadData() async {
    List<PendingNotificationRequest> pendingReminders = await FlutterLocalNotificationsPlugin().pendingNotificationRequests();
    for (PendingNotificationRequest reminder in pendingReminders) {
      Show reminderShow = Show.fromJson(jsonDecode(reminder.payload)['show']);
      Channel reminderChannel = Channel.fromJson(jsonDecode(reminder.payload)['channel']);
      if (reminderShow.key == widget.show.key && reminderChannel.provider == widget.channel.provider) {
        setState(() {
          this. reminder = reminder;
          this.loaded = true;
        });
        return;
      }
    }
    setState(() {
      this. reminder = null;
      this.loaded = true;
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.show.startDate.isBefore(DateTime.now())) {
      return RaisedButton.icon(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)
        ),
        icon: Icon(MdiIcons.bellOutline),
        label: Text('התוכנית כבר שודרה'),
        disabledColor: Theme.of(context).brightness == Brightness.light ? Colors.black12 : Colors.white12,
        onPressed: null
      );
    }
    if (loaded) {
      if (reminder != null) {
        return RaisedButton.icon(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)
            ),
            icon: Icon(MdiIcons.bellRingOutline),
            label: Text('אנחנו נזכיר לך 5 דק\' לפני תחילת התוכנית'),
            color: Theme.of(context).accentColor,
            textColor: Colors.white,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: new Text('האם ברצונך להסיר את התזכורת?'),
                    actions: <Widget>[
                      FlatButton(
                        child: new Text("לא"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: new Text("כן"),
                        onPressed: () {
                          FlutterLocalNotificationsPlugin().cancel(reminder.id);
                          Navigator.of(context).pop();
                          setState(() {
                            this. reminder = null;
                            this.loaded = true;
                          });
                        }
                      )
                    ]
                  );
                },
              );
            }
        );
      } else {
        return RaisedButton.icon(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)
          ),
          icon: Icon(MdiIcons.bellOutline),
          label: Text('הפעל תזכורת'),
          color: Theme.of(context).accentColor.withAlpha(170),
          textColor: Colors.white,
          onPressed: registerReminder
        );
      }
    } else {
      return Container();
    }
  }

  registerReminder() async {
    String title = 'התוכנית ״${widget.showDetails.title}״ תתחיל בקרוב';
    String body = 'התוכנית תשודר בשעה ' + widget.show.getStartTime() + ' ב־' + widget.channel.name + '. צפייה מהנה!';
    DateTime date = widget.showDetails.startDate.subtract(Duration(minutes: 5));
//    DateTime date = DateTime.now().add(Duration(seconds: 3));
    Map payload = {
      'show': widget.show.toJson(),
      'show-details': widget.showDetails.toJson(),
      'channel': widget.channel.toJson(),
    };

    FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
    InitializationSettings initializationSettings = InitializationSettings(
        AndroidInitializationSettings('app_icon'),
        IOSInitializationSettings(onDidReceiveLocalNotification: null)
    );
    notifications.initialize(initializationSettings, onSelectNotification: (String payload) {

    });

    NotificationDetails channelDetails = NotificationDetails(
        AndroidNotificationDetails('show_reminder', 'התוכנית עומדת להתחיל', 'תזכורות לפני תוכניות מועדפות'),
        IOSNotificationDetails()
    );

    List<PendingNotificationRequest> padding = await notifications.pendingNotificationRequests();
    int id = 0;
    if (padding.length > 0) {
      id = padding[padding.length - 1].id + 1;
    }
    await notifications.schedule(id, title, body, date, channelDetails, payload: jsonEncode(payload));
    loadData();

    FirebaseAnalytics().logEvent(name: 'reminder_registered',
      parameters: <String, dynamic>{
        'show_name': widget.show.title,
        'channel_name': widget.channel.name,
        'channel_provider': widget.channel.provider
      }
    );
  }
}


class HideScrollGlow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}