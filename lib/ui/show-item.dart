import 'package:flutter/material.dart';
import '../model/show.dart';

class ShowItem extends StatelessWidget {

  const ShowItem({
    @required this.show,
    @required this.onTap,
    Key key,
    this.isCurrently = false
  }) : super(key: key);

  final Show show;
  final GestureTapCallback onTap;
  final bool isCurrently;

  @override
  Widget build(BuildContext context) {
    if (show.title.contains("נשוב לשדר") || show.title.contains("שידורינו יתחדשו")) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        color: Theme.of(context).brightness == Brightness.light ? Colors.black12 : Colors.white12,
        child: Text(show.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500), textAlign: TextAlign.center)
      );
    }
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        child: Row(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(show.getStartTime(), style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isCurrently ? Theme.of(context).accentColor : null
                ))
            ),
            Flexible(
              child: Text(show.title, style: TextStyle(
                  fontSize: 15,
                  fontWeight: isCurrently ? FontWeight.w500 : FontWeight.w400,
                  color: isCurrently ? Theme.of(context).accentColor : null
              ))
              // TODO: Add overflow: https://github.com/flutter/flutter/issues/16450
            )
          ]
        )
      )
    );
  }
}