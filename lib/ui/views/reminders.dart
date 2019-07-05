import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import './show.dart';
import '../../model/show.dart';
import '../../model/show-details.dart';
import '../../model/channel.dart';

class RemindersPage extends StatefulWidget {

  @override
  RemindersPageState createState() => RemindersPageState();
}

class RemindersPageState extends State<RemindersPage> {

  FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
  List<PendingNotificationRequest> pendingReminders;

  @override
  void initState() {
    super.initState();
    loadReminders();
  }

  loadReminders() async {
    List<PendingNotificationRequest> pendingReminders = await notifications.pendingNotificationRequests();
    setState(() {
      this.pendingReminders = pendingReminders;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Center(
        child: CircularProgressIndicator()
    );
    if (pendingReminders != null && pendingReminders.length <= 0) {
      body = Center(
          child: Text('אין תזכורות', style: Theme.of(context).textTheme.title)
      );
    } else if (pendingReminders != null && pendingReminders.length > 0) {
      body = ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: Colors.black26,
        ),
        itemCount:  pendingReminders.length,
        itemBuilder: (BuildContext context, int index) {
          PendingNotificationRequest reminder = pendingReminders[index];
          Map payload = jsonDecode(reminder.payload);
          Show show = Show.fromJson(payload['show']);
          ShowDetails showDetails = ShowDetails.fromJson(payload['show-details']);
          Channel channel = Channel.fromJson(payload['channel']);

          return ListTile(
            title: Text(showDetails.title),
            subtitle: Text(DateFormat('dd/MM בשעה HH:mm').format(showDetails.startDate) + ' - ' + channel.name),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (c) {
                    return ShowPage(show, channel, null);
                  }
              )).then((data) {
                loadReminders();
              });
            },
            trailing: IconButton(
              icon: Icon(MdiIcons.deleteOutline),
              tooltip: 'מחיקת תזכורת',
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
                            notifications.cancel(reminder.id);
                            Navigator.of(context).pop();
                            loadReminders();
                          },
                        )
                      ],
                    );
                  },
                );
              }
            )
          );
        }
      );
    }
    return Scaffold(
      appBar: AppBar(
          title: Text('תזכורות')
      ),
      body: body
    );
  }
}
