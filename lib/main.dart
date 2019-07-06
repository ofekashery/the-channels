import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'providers/cache.dart';
import 'providers/channels.dart';
import 'model/channel.dart';
import 'ui/views/home.dart';
import 'ui/views/reminders.dart';
import 'ui/views/settings.dart';
import 'ui/views/all-channels.dart';

void main() {
  Admob.initialize('ca-app-pub-3335065154506773~2826781038');
  FirebaseAnalytics().setAnalyticsCollectionEnabled(true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  loadTheme(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DynamicTheme.of(context).setBrightness((prefs.getBool(Keys.darkTheme) ?? false) ? Brightness.dark : Brightness.light);
  }

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'he_IL';

    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => ThemeData(
        primaryColor: brightness == Brightness.light ? Colors.white : Color(0xFF222427),
        scaffoldBackgroundColor: brightness == Brightness.light ? null : Color(0xFF121212),
        accentColor: Color(0xFF1888FD),
        fontFamily: 'Rubik',
        brightness: brightness
      ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          title: 'הערוצים',
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: MyHomePage(),
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
          ],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            Locale("he", "IL")
          ],
          locale: Locale("he", "IL")
        );
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final PanelController panelController = PanelController();
  Widget home;
  Widget panel;
  double position = 0;

  @override
  Widget build(BuildContext context) {
    if (home == null || panel == null) {
      home = HomePage();
      panel = AllChannelsPage();
    } else {
      Channels.getFavoriteChannels().then((List<Channel> channels) async {
        dynamic cache = await Cache.get('last-favorite-channels');
        List<String> newKeys = channels.map((Channel channel) => '${channel.provider}-${channel.key}').toList();
        List<String> oldKeys = cache != null ? cache.toList().cast<String>() : [];
        newKeys.sort();
        oldKeys.sort();

        if (newKeys.join(',') != oldKeys.join(',')) {
          await Cache.set('last-favorite-channels', newKeys, null);
          setState(() {
            home = HomePage();
          });
        }
      });
    }

    BorderRadiusGeometry panelRadius = BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
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
          child: panel
        ),
        boxShadow: [],
        minHeight: 80,
        maxHeight: MediaQuery.of(context).size.height * 9 / 11,
        controller: panelController,
        collapsed: getBottomAppBar(),
        body: Scaffold(
          appBar: AppBar(
            title: Center(
              child: Text('הערוצים'),
            )
          ),
          body: home
        ),
      ),
    );
  }

  Widget getBottomAppBar(){
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton:  FloatingActionButton.extended(
        onPressed: () => panelController.open(),
        elevation: 4,
        icon: Icon(MdiIcons.chevronUp),
        label: Text('כל הערוצים')
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(MdiIcons.settingsOutline),
              tooltip: 'הגדרות',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (c) {
                      return SettingsPage();
                    }
                  )
                );
              }
            ),
            IconButton(
              icon: Icon(MdiIcons.bellOutline),
              tooltip: 'תזכורות',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (c) {
                      return RemindersPage();
                    }
                  )
                );
              }
            )
          ],
        ),
      )
    );
  }
}
