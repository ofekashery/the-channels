import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import '../../providers/channels.dart';

class SettingsPage extends StatefulWidget {

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {

  String applicationVersion = '4.0.1';
  SharedPreferences prefs;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    loadSharedPreferences();
  }

  loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      this.prefs = prefs;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Center(
      child: CircularProgressIndicator()
    );

    if (prefs != null) {
      body = ListView(
        children: <Widget>[
          ListTile(
            title: Text('ערכת נושא'),
            leading: Icon(MdiIcons.themeLightDark),
            onTap: () {
              showDialog<bool>(context: context, builder: (BuildContext context) => SimpleDialog(
                title: Text('בחר ערכת נושא'),
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    onTap: () => Navigator.pop(context, false),
                    title: Text('בהיר')
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    onTap: () => Navigator.pop(context, true),
                    title: Text('כהה')
                  )
                ],
              )).then((bool value) {
                if (value != null) {
                  setState(() {
                    DynamicTheme.of(context).setBrightness(value ? Brightness.dark : Brightness.light);
                    prefs.setBool(Keys.darkTheme, value);
                  });
                }
              });
            }
          ),
          ListTile(
            title: Text('מחיקת הערוצים המועדפים'),
            leading: Icon(MdiIcons.deleteOutline),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: new Text('האם ברצונך למחוק את כל הערוצים המועדפים?'),
                    actions: <Widget>[
                      FlatButton(
                        child: new Text("לא"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: new Text("כן"),
                        onPressed: () async {
                          await Channels.clearFavoriteChannels();
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            title: Text('שיתוף האפליקצייה'),
            leading: Icon(MdiIcons.shareVariant),
            onTap: () {
              FirebaseAnalytics().logShare(contentType: 'text', itemId: 'app_settings');
              Share.share('אני משתמש באפליקציית "הערוצים" כדי לראות את לוח השידורים ולקבל תזכורות לתוכניות האהובות עליי - https://ofek.ashery.me/tv');
            },
          ),
          Divider(
            color: Colors.black26,
            height: 24,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text('אודות', style: Theme.of(context).textTheme.subtitle),
          ),
          ListTile(
            title: Text('מדיניות פרטיות', style: TextStyle(color: Color(0xFF2273DC),fontWeight: FontWeight.w600)),
            onTap: () => openLink('https://ofek.ashery.me/projects/the-channels/privacy-policy')
          ),
          ListTile(
            title: Text('רשיונות קוד פתוח', style: TextStyle(color: Color(0xFF2273DC),fontWeight: FontWeight.w600)),
            onTap: () {
              showLicensePage(
                context: context,
                applicationVersion: applicationVersion
              );
            }
          ),
          ListTile(
            title: Text('קוד פתוח (GitHub)', style: TextStyle(color: Color(0xFF2273DC),fontWeight: FontWeight.w600)),
            onTap: () => openLink('https://github.com/ofekashery/the-channels')
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('גרסה $applicationVersion')
          ),
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: ListTile(
              title: Text('פותח על ידי אופק אשרי', textAlign: TextAlign.center),
              onTap: () => openLink('https://ofek.ashery.me')
            )
          )
        ],
      );
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('הגדרות')
      ),
      body: body
    );
  }

  openLink(String url) async {
    if (await canLaunch(url)) {
      launch(url);
    } else {
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('לא ניתן לפתוח את הקישור')));
    }
  }
}

class Keys {
  static String darkTheme = 'S-DARK';
}